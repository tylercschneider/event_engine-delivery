module EventEngine
  module Delivery
    # The delivery handler registered with EventEngine core. Receives a built
    # Event and routes it by level: level 1 invokes subscribers in-process,
    # level 2 enqueues that dispatch, levels 3+ write to the outbox and publish.
    class Handler
      def call(event)
        case event.event_level
        when 1 then dispatch_synchronously(event)
        when 2 then dispatch_in_background(event)
        else write_and_publish(event)
        end
      end

      private

      def dispatch_synchronously(event)
        ::EventEngine::SubscriberRegistry.subscribers_for(event.event_name).each do |subscriber|
          subscriber.new.handle(event)
        end
        event
      end

      def dispatch_in_background(event)
        DispatchSubscribersJob.perform_later(event.event_name.to_s, event.to_h)
        event
      end

      def write_and_publish(event)
        outbox_event = OutboxWriter.write(event.to_h)

        ActiveSupport::Notifications.instrument("event_engine.event_emitted", {
          event_name: outbox_event.event_name,
          event_version: outbox_event.event_version,
          event_id: outbox_event.id,
          idempotency_key: outbox_event.idempotency_key,
          aggregate_type: outbox_event.aggregate_type,
          aggregate_id: outbox_event.aggregate_id,
          aggregate_version: outbox_event.aggregate_version
        })

        Delivery.enqueue do
          transport = Delivery.configuration.transport
          unless transport
            Rails.logger.warn("[EventEngine::Delivery] No transport configured — event written to outbox but not published. " \
              "Set config.transport in your EventEngine::Delivery initializer to enable publishing.")
            next
          end

          OutboxPublisher.new(
            router: OutboxRouter.new(transport: transport),
            batch_size: Delivery.configuration.batch_size
          ).call
        end

        outbox_event
      end
    end
  end
end
