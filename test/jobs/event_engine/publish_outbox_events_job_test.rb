require "test_helper"

class EventEngine::PublishOutboxEventsJobTest < ActiveJob::TestCase
  test "job invokes the outbox publisher" do
    event = EventEngine::OutboxEvent.create!(
      event_type: "OrderCreated",
      event_name: "order.created",
      event_version: 1,
      occurred_at: Time.current,
      payload: { filler: "x" }
    )

    transport = EventEngine::Transports::InMemoryTransport.new
    EventEngine.configure { |c| c.transport = transport }

    EventEngine::PublishOutboxEventsJob.perform_now

    assert_not_nil event.reload.published_at
    assert_equal [event], transport.events
  end

  test "job uses configured transport" do
    event = EventEngine::OutboxEvent.create!(
      event_type: "OrderCreated",
      event_name: "order.created",
      event_version: 1,
      occurred_at: Time.current,
      payload: { filler: "x" }
    )

    transport = EventEngine::Transports::InMemoryTransport.new
    EventEngine.configure { |c| c.transport = transport }

    EventEngine::PublishOutboxEventsJob.perform_now

    assert_equal [event], transport.events
    assert_not_nil event.reload.published_at
  end

  test "raises a clear error when transport is not configured" do
    EventEngine.configure { |c| c.transport = nil }

    error = assert_raises(RuntimeError) do
      EventEngine::PublishOutboxEventsJob.perform_now
    end

    assert_match "EventEngine transport not configured", error.message
  end

  test "job respects configured batch size" do
    e1 = EventEngine::OutboxEvent.create!(event_type: "A", event_name: "a", event_version: 1, occurred_at: Time.current, payload: { x: 1 })
    e2 = EventEngine::OutboxEvent.create!(event_type: "A", event_name: "a", event_version: 1, occurred_at: Time.current, payload: { x: 2 })
    e3 = EventEngine::OutboxEvent.create!(event_type: "A", event_name: "a", event_version: 1, occurred_at: Time.current, payload: { x: 3 })

    transport = EventEngine::Transports::InMemoryTransport.new
    EventEngine.configure do |c|
      c.transport = transport
      c.batch_size = 2
    end

    EventEngine::PublishOutboxEventsJob.perform_now

    assert_equal [e1, e2], transport.events
    assert_nil e3.reload.published_at
  end

  test "job invokes outbox publisher with configured transport and options" do
      event = EventEngine::OutboxEvent.create!(
        event_type: "A",
        event_name: "a",
        event_version: 1,
        occurred_at: Time.current,
        payload: { x: 1 }
      )

      transport = EventEngine::Transports::InMemoryTransport.new

      EventEngine.configuration.transport = transport
      EventEngine.configuration.batch_size = 10
      EventEngine.configuration.max_attempts = 5

      EventEngine::PublishOutboxEventsJob.new.perform

      assert_equal [event], transport.events
      assert_not_nil event.reload.published_at
    end
end
