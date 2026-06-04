require "test_helper"

module EventEngine
  class OutboxEventConstraintsTest < ActiveSupport::TestCase
    test "event_name NOT NULL is enforced at the database level" do
      assert_raises ActiveRecord::NotNullViolation do
        OutboxEvent.new(
          event_name: nil,
          event_type: "domain",
          event_version: 1,
          occurred_at: Time.current,
          payload: { filler: "x" }
        ).save!(validate: false)
      end
    end
  end
end
