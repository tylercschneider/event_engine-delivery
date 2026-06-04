require "test_helper"

module EventEngine
  module Dashboard
    class EventsControllerTest < ActionDispatch::IntegrationTest
      setup do
        EventEngine.configuration.dashboard_auth = ->(_) { true }
      end

      teardown do
        EventEngine.configuration.dashboard_auth = nil
      end

      test "index lists events with pagination" do
        25.times do |i|
          OutboxEvent.create!(
            event_name: "order.created",
            event_type: "domain",
            event_version: 1,
            payload: { order_id: i },
            occurred_at: Time.current,
            idempotency_key: SecureRandom.uuid
          )
        end

        get event_engine.dashboard_events_path

        assert_response :success
        assert_select "table"
        assert_select "tr.event-row", 20  # Default per page
        assert_select "a", text: /Next/
      end

      test "index paginates to page 2" do
        25.times do |i|
          OutboxEvent.create!(
            event_name: "order.created",
            event_type: "domain",
            event_version: 1,
            payload: { order_id: i },
            occurred_at: Time.current,
            idempotency_key: SecureRandom.uuid
          )
        end

        get event_engine.dashboard_events_path(page: 2)

        assert_response :success
        assert_select "tr.event-row", 5  # Remaining events
        assert_select "a", text: /Previous/
      end

      test "show displays event details with payload" do
        event = OutboxEvent.create!(
          event_name: "order.created",
          event_type: "domain",
          event_version: 1,
          payload: { order_id: 123, customer: "John" },
          occurred_at: Time.current,
          idempotency_key: "test-key-123"
        )

        get event_engine.dashboard_event_path(event)

        assert_response :success
        assert_select "h1", /order\.created/
        assert_select ".payload", /order_id/
        assert_select ".payload", /123/
      end
    end
  end
end
