require "test_helper"

module EventEngine
  module Dashboard
    class DeadLettersControllerTest < ActionDispatch::IntegrationTest
      setup do
        EventEngine.configuration.dashboard_auth = ->(_) { true }
      end

      teardown do
        EventEngine.configuration.dashboard_auth = nil
      end

      test "index lists dead-lettered events" do
        3.times do |i|
          OutboxEvent.create!(
            event_name: "order.failed",
            event_type: "domain",
            event_version: 1,
            payload: { order_id: i },
            occurred_at: Time.current,
            dead_lettered_at: Time.current,
            attempts: 5,
            idempotency_key: SecureRandom.uuid
          )
        end

        # Non-dead-lettered event should not appear
        OutboxEvent.create!(
          event_name: "order.created",
          event_type: "domain",
          event_version: 1,
          payload: { order_id: 99 },
          occurred_at: Time.current,
          idempotency_key: SecureRandom.uuid
        )

        get event_engine.dashboard_dead_letters_path

        assert_response :success
        assert_select "tr.dead-letter-row", 3
      end

      test "retry action retries a dead-lettered event" do
        event = OutboxEvent.create!(
          event_name: "order.failed",
          event_type: "domain",
          event_version: 1,
          payload: { order_id: 1 },
          occurred_at: Time.current,
          dead_lettered_at: Time.current,
          attempts: 5,
          idempotency_key: SecureRandom.uuid
        )

        post event_engine.retry_dashboard_dead_letter_path(event)

        assert_redirected_to event_engine.dashboard_dead_letters_path

        event.reload
        assert_equal 0, event.attempts
        assert_nil event.dead_lettered_at
      end

      test "retry_all action retries all dead-lettered events" do
        3.times do |i|
          OutboxEvent.create!(
            event_name: "order.failed",
            event_type: "domain",
            event_version: 1,
            payload: { order_id: i },
            occurred_at: Time.current,
            dead_lettered_at: Time.current,
            attempts: 5,
            idempotency_key: SecureRandom.uuid
          )
        end

        post event_engine.retry_all_dashboard_dead_letters_path

        assert_redirected_to event_engine.dashboard_dead_letters_path
        assert_equal 0, OutboxEvent.dead_lettered.count
      end
    end
  end
end
