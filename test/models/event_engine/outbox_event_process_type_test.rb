require "test_helper"

module EventEngine
  class OutboxEventProcessTypeTest < ActiveSupport::TestCase
    test "stores and reads back a process_type" do
      event = OutboxEvent.create!(
        event_name: "cow.fed",
        event_type: "domain",
        event_version: 1,
        occurred_at: Time.current,
        payload: { weight: 1200 },
        process_type: "durable"
      )

      assert_equal "durable", event.reload.process_type
    end
  end
end
