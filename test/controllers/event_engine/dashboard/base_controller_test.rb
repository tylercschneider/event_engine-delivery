require "test_helper"

module EventEngine
  module Dashboard
    class BaseControllerTest < ActionDispatch::IntegrationTest
      setup do
        @original_auth = EventEngine.configuration.dashboard_auth
      end

      teardown do
        EventEngine.configuration.dashboard_auth = @original_auth
      end

      test "returns 403 when dashboard_auth is not configured" do
        EventEngine.configuration.dashboard_auth = nil

        get event_engine.dashboard_root_path

        assert_response :forbidden
      end

      test "logs a warning when dashboard_auth is nil" do
        EventEngine.configuration.dashboard_auth = nil

        log_output = StringIO.new
        original_logger = EventEngine.configuration.logger
        EventEngine.configuration.logger = Logger.new(log_output)

        get event_engine.dashboard_root_path

        EventEngine.configuration.logger = original_logger

        assert_match(/dashboard_auth/, log_output.string)
      end

      test "returns 403 when dashboard_auth returns false" do
        EventEngine.configuration.dashboard_auth = ->(_controller) { false }

        get event_engine.dashboard_root_path

        assert_response :forbidden
      end

      test "allows access when dashboard_auth returns true" do
        EventEngine.configuration.dashboard_auth = ->(_controller) { true }

        get event_engine.dashboard_root_path

        assert_response :success
      end
    end
  end
end
