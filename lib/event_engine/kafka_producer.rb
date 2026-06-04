require "json"

module EventEngine
  class KafkaProducer
    def initialize(client:)
      @client = client
    end

    def publish(topic, payload)
      @client.produce(
        JSON.generate(payload),
        topic: topic
      )
    end
  end
end
