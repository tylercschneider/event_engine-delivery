module EventEngine
  module Delivery
    # The delivery handler registered with EventEngine core. Receives a built
    # Event and handles only durable/broker events: it writes them to the outbox
    # and publishes them. :inline and :background events are run by
    # event_engine-subscribers, not here. Falls back to the legacy integer
    # event_level when process_type is absent.
    class Handler
      def call(event)
        case process_type_for(event)
        when :inline, :background then nil # run by event_engine-subscribers
        else write_and_publish(event)
        end
      end

      private

      def process_type_for(event)
        (event.process_type || ProcessType.from_event_level(event.event_level))&.to_sym
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
