module EventEngine
  module Cloud
    # Subscribes to +ActiveSupport::Notifications+ and feeds serialized
    # event metadata to the {Reporter}.
    class Subscribers
      class << self
        # Subscribes to all EventEngine notifications.
        #
        # @param reporter [Reporter] the reporter to send entries to
        # @return [void]
        def subscribe!(reporter:)
          @subscriptions = []
          @reporter = reporter

          @subscriptions << ActiveSupport::Notifications.subscribe("event_engine.event_emitted") do |*, payload|
            entry = Serializer.serialize_emit(payload)
            @reporter.track_emit(entry)
          end

          @subscriptions << ActiveSupport::Notifications.subscribe("event_engine.event_published") do |*, payload|
            entry = Serializer.serialize_publish(payload)
            @reporter.track_publish(entry)
          end

          @subscriptions << ActiveSupport::Notifications.subscribe("event_engine.event_dead_lettered") do |*, payload|
            entry = Serializer.serialize_dead_letter(payload)
            @reporter.track_dead_letter(entry)
          end
        end

        # Removes all notification subscriptions.
        #
        # @return [void]
        def unsubscribe!
          return unless @subscriptions

          @subscriptions.each do |subscription|
            ActiveSupport::Notifications.unsubscribe(subscription)
          end
          @subscriptions = nil
          @reporter = nil
        end
      end
    end
  end
end
