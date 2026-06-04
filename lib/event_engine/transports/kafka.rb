module EventEngine
  module Transports
    # Publishes events to Kafka topics via an injected producer.
    # Topics are named +events.{event_name}+ by default.
    #
    # @example
    #   producer = EventEngine::KafkaProducer.new(client: kafka_client)
    #   transport = EventEngine::Transports::Kafka.new(producer: producer)
    class Kafka
      # @param producer [KafkaProducer] a producer that responds to +#publish(topic, payload)+
      def initialize(producer:)
        @producer = producer
      end

      # Publishes the event to a Kafka topic.
      #
      # @param event [OutboxEvent]
      # @return [Object] the producer's return value
      def publish(event)
        @producer.publish(topic_for(event), payload_for(event))
      end

      private

      def topic_for(event)
        "events.#{event.event_name}"
      end

      def payload_for(event)
        {
          event_name: event.event_name,
          event_type: event.event_type,
          event_version: event.event_version,
          idempotency_key: event.idempotency_key,
          payload: event.payload,
          metadata: event.metadata,
          occurred_at: event.occurred_at,
          aggregate_type: event.aggregate_type,
          aggregate_id: event.aggregate_id,
          aggregate_version: event.aggregate_version
        }
      end
    end
  end
end
