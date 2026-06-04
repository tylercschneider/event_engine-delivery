require "test_helper"
require "rake"

module EventEngine
  class OutboxCleanupTasksTest < ActiveSupport::TestCase
    setup do
      Rails.application.load_tasks
      Rake::Task.tasks.each(&:reenable)

      @original_retention = EventEngine.configuration.retention_period
    end

    teardown do
      EventEngine.configuration.retention_period = @original_retention
    end

    test "outbox:cleanup deletes old published events" do
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

      output = capture_io do
        Rake::Task["event_engine:outbox:cleanup"].invoke
      end.first

      assert_not OutboxEvent.exists?(old_event.id)
      assert OutboxEvent.exists?(recent_event.id)
      assert_match(/deleted 1 event/i, output)
    end

    test "outbox:cleanup never deletes unpublished events" do
      EventEngine.configuration.retention_period = 30.days

      unpublished = OutboxEvent.create!(
        event_name: "order.created",
        event_type: "domain",
        event_version: 1,
        payload: { order_id: 1 },
        occurred_at: 40.days.ago
      )

      capture_io do
        Rake::Task["event_engine:outbox:cleanup"].invoke
      end

      assert OutboxEvent.exists?(unpublished.id)
    end

    test "outbox:cleanup never deletes dead-lettered events" do
      EventEngine.configuration.retention_period = 30.days

      dead_lettered = OutboxEvent.create!(
        event_name: "order.created",
        event_type: "domain",
        event_version: 1,
        payload: { order_id: 1 },
        occurred_at: 40.days.ago,
        published_at: 40.days.ago,
        dead_lettered_at: 40.days.ago
      )

      capture_io do
        Rake::Task["event_engine:outbox:cleanup"].invoke
      end

      assert OutboxEvent.exists?(dead_lettered.id)
    end

    test "outbox:cleanup warns when retention_period not configured" do
      EventEngine.configuration.retention_period = nil

      output = capture_io do
        Rake::Task["event_engine:outbox:cleanup"].invoke
      end.first

      assert_match(/retention_period not configured/i, output)
    end
  end
end
