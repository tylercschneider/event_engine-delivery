require "test_helper"

module EventEngine
  class OutboxCleanupJobTest < ActiveSupport::TestCase
    setup do
      @original_retention = EventEngine.configuration.retention_period
    end

    teardown do
      EventEngine.configuration.retention_period = @original_retention
    end

    test "deletes old published events" do
      EventEngine.configuration.retention_period = 30.days

      old_event = OutboxEvent.create!(
        event_name: "order.created",
        event_type: "domain",
        event_version: 1,
        payload: { order_id: 1 },
        occurred_at: 40.days.ago,
        published_at: 40.days.ago
      )

      recent_event = OutboxEvent.create!(
        event_name: "order.created",
        event_type: "domain",
        event_version: 1,
        payload: { order_id: 2 },
        occurred_at: 5.days.ago,
        published_at: 5.days.ago,
        idempotency_key: SecureRandom.uuid
      )

      OutboxCleanupJob.perform_now

      assert_not OutboxEvent.exists?(old_event.id)
      assert OutboxEvent.exists?(recent_event.id)
    end

    test "does nothing when retention_period not configured" do
      EventEngine.configuration.retention_period = nil

      event = OutboxEvent.create!(
        event_name: "order.created",
        event_type: "domain",
        event_version: 1,
        payload: { order_id: 1 },
        occurred_at: 40.days.ago,
        published_at: 40.days.ago
      )

      OutboxCleanupJob.perform_now

      assert OutboxEvent.exists?(event.id)
    end
  end
end
