require "test_helper"

class EventEngine::ReRunPublishTest < ActiveSupport::TestCase
  test "re-running the job does not re-publish events" do
    event = EventEngine::OutboxEvent.create!(
      event_type: "OrderCreated",
      event_name: "order.created",
      event_version: 1,
      occurred_at: Time.current,
      payload: { filler: "x" }
    )

    transport = EventEngine::Transports::InMemoryTransport.new
    EventEngine.configure { |c| c.transport = transport }

    # first run
    EventEngine::PublishOutboxEventsJob.perform_now

    # second run
    EventEngine::PublishOutboxEventsJob.perform_now

    assert_equal [event], transport.events
    assert_not_nil event.reload.published_at
  end
end
