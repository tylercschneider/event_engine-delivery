require "test_helper"

module EventEngine
  module Dashboard
    class BaseControllerTest < ActionDispatch::IntegrationTest
      setup do
        @original_auth = EventEngine::Delivery.configuration.dashboard_auth
      end

      teardown do
        EventEngine::Delivery.configuration.dashboard_auth = @original_auth
      end

      test "returns 403 when dashboard_auth is not configured" do
        EventEngine::Delivery.configuration.dashboard_auth = nil

        get event_engine.dashboard_root_path

        assert_response :forbidden
      end

      test "logs a warning when dashboard_auth is nil" do
        EventEngine::Delivery.configuration.dashboard_auth = nil

        log_output = StringIO.new
        original_logger = EventEngine::Delivery.configuration.logger
        EventEngine::Delivery.configuration.logger = Logger.new(log_output)

        get event_engine.dashboard_root_path

        EventEngine::Delivery.configuration.logger = original_logger

        assert_match(/dashboard_auth/, log_output.string)
      end

      test "returns 403 when dashboard_auth returns false" do
        EventEngine::Delivery.configuration.dashboard_auth = ->(_controller) { false }

        get event_engine.dashboard_root_path

        assert_response :forbidden
      end

      test "allows access when dashboard_auth returns true" do
        EventEngine::Delivery.configuration.dashboard_auth = ->(_controller) { true }

        get event_engine.dashboard_root_path

        assert_response :success
      end
    end
  end
end
