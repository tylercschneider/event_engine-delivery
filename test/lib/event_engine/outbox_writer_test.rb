require "test_helper"

module EventEngine
  class OutboxWriterTest < ActiveSupport::TestCase
    test "writes an OutboxEvent with given attributes" do
      attrs = {
        event_name: :cow_fed,
        event_type: :domain,
        event_version: 1,
        occurred_at: Time.current,
        payload: { weight: 500 }
      }

      event = OutboxWriter.write(attrs)

      assert event.persisted?
      assert_equal "cow_fed", event.event_name
      assert_equal "domain", event.event_type
      assert_equal({ "weight" => 500 }, event.payload)
    end
  end
end
