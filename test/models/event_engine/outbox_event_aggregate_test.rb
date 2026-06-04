require "test_helper"

module EventEngine
  class OutboxEventAggregateTest < ActiveSupport::TestCase
    test "for_aggregate scope returns events matching type and id" do
      matching = OutboxEvent.create!(
        event_name: "order.created",
        event_type: "domain",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "x" },
        aggregate_type: "Order",
        aggregate_id: "order-123"
      )

      other_type = OutboxEvent.create!(
        event_name: "order.created",
        event_type: "domain",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "x" },
        aggregate_type: "User",
        aggregate_id: "user-456"
      )

      other_id = OutboxEvent.create!(
        event_name: "order.created",
        event_type: "domain",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "x" },
        aggregate_type: "Order",
        aggregate_id: "order-999"
      )

      results = OutboxEvent.for_aggregate("Order", "order-123")
      assert_includes results, matching
      assert_not_includes results, other_type
      assert_not_includes results, other_id
    end

    test "next_aggregate_version returns 1 for new aggregate" do
      assert_equal 1, OutboxEvent.next_aggregate_version("Order", "order-new")
    end

    test "next_aggregate_version returns max + 1 for existing aggregate" do
      OutboxEvent.create!(
        event_name: "order.created",
        event_type: "domain",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "x" },
        aggregate_type: "Order",
        aggregate_id: "order-123",
        aggregate_version: 3
      )

      assert_equal 4, OutboxEvent.next_aggregate_version("Order", "order-123")
    end
  end
end
