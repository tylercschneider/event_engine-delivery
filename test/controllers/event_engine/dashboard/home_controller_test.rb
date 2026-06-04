require "test_helper"

module EventEngine
  module Dashboard
    class HomeControllerTest < ActionDispatch::IntegrationTest
      setup do
        EventEngine.configuration.dashboard_auth = ->(_) { true }
      end

      teardown do
        EventEngine.configuration.dashboard_auth = nil
      end

      test "index shows outbox stats" do
        # Create test events
        3.times do |i|
          OutboxEvent.create!(
            event_name: "order.created",
            event_type: "domain",
            event_version: 1,
            payload: { order_id: i },
            occurred_at: Time.current,
            idempotency_key: SecureRandom.uuid
          )
        end

        2.times do |i|
          OutboxEvent.create!(
            event_name: "order.shipped",
            event_type: "domain",
            event_version: 1,
            payload: { order_id: i + 10 },
            occurred_at: Time.current,
            published_at: Time.current,
            idempotency_key: SecureRandom.uuid
          )
        end

        OutboxEvent.create!(
          event_name: "order.failed",
          event_type: "domain",
          event_version: 1,
          payload: { order_id: 99 },
          occurred_at: Time.current,
          dead_lettered_at: Time.current,
          idempotency_key: SecureRandom.uuid
        )

        get event_engine.dashboard_root_path

        assert_response :success
        assert_select "h1", "EventEngine Dashboard"
        assert_select ".stat-total", /6/
        assert_select ".stat-published", /2/
        assert_select ".stat-unpublished", /3/
        assert_select ".stat-dead-lettered", /1/
      end
    end
  end
end
