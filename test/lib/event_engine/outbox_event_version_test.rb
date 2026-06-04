require "test_helper"
require "ostruct"

class OutboxEventVersionTest < ActiveSupport::TestCase
  test "outbox event persists event_version" do
    event = EventEngine::OutboxEvent.create!(
      event_name: "cow_fed",
      event_type: "domain",
      event_version: 2,
      occurred_at: Time.current,
      payload: { "weight" => 500 }
    )

    assert_equal 2, event.event_version
  end
end
