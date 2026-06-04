require "test_helper"

module EventEngine
  class KafkaProducerWrapperTest < ActiveSupport::TestCase
    test "publishes serialized payload to kafka client" do
      client = FakeKafkaClient.new
      producer = EventEngine::KafkaProducer.new(client: client)

      producer.publish("events.cow_fed", { a: 1 })

      assert_equal 1, client.messages.size
      message = client.messages.first

      assert_equal "events.cow_fed", message[:topic]
      assert_equal '{"a":1}', message[:payload]
    end

    private

    class FakeKafkaClient
      attr_reader :messages

      def initialize
        @messages = []
      end

      def produce(payload, topic:)
        @messages << { topic: topic, payload: payload }
      end
    end
  end
end
