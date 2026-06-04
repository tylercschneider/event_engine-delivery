require "test_helper"

class KafkaTransportTest < ActiveSupport::TestCase
  def test_publishes_event_payload_to_producer
    event = EventEngine::OutboxEvent.new(
      event_name: "cow.fed",
      event_type: "domain",
      event_version: 1,
      payload: { amount: 5 },
      metadata: {},
      occurred_at: Time.current
    )

    producer = FakeKafkaProducer.new
    transport = EventEngine::Transports::Kafka.new(producer: producer)

    transport.publish(event)

    assert_equal 1, producer.published.size
    published = producer.published.first

    assert_equal "events.cow.fed", published[:topic]
    assert_equal "cow.fed", published[:payload][:event_name]
  end

  def test_includes_idempotency_key_in_payload
    event = EventEngine::OutboxEvent.new(
      event_name: "cow.fed",
      event_type: "domain",
      event_version: 1,
      payload: { amount: 5 },
      metadata: {},
      occurred_at: Time.current,
      idempotency_key: "unique-key-123"
    )

    producer = FakeKafkaProducer.new
    transport = EventEngine::Transports::Kafka.new(producer: producer)

    transport.publish(event)

    published = producer.published.first
    assert_equal "unique-key-123", published[:payload][:idempotency_key]
  end

  def test_includes_aggregate_fields_in_payload
    event = EventEngine::OutboxEvent.new(
      event_name: "order.created",
      event_type: "domain",
      event_version: 1,
      payload: { total: 99 },
      metadata: {},
      occurred_at: Time.current,
      aggregate_type: "Order",
      aggregate_id: "order-42",
      aggregate_version: 3
    )

    producer = FakeKafkaProducer.new
    transport = EventEngine::Transports::Kafka.new(producer: producer)

    transport.publish(event)

    published = producer.published.first
    assert_equal "Order", published[:payload][:aggregate_type]
    assert_equal "order-42", published[:payload][:aggregate_id]
    assert_equal 3, published[:payload][:aggregate_version]
  end

  private

  class FakeKafkaProducer
    attr_reader :published

    def initialize
      @published = []
    end

    def publish(topic, payload)
      @published << { topic:, payload: }
    end
  end
end
