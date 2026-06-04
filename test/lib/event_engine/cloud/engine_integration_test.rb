require "test_helper"
require "webmock/minitest"

module EventEngine
  module Cloud
    class EngineIntegrationTest < ActiveSupport::TestCase
      setup do
        Reporter.reset!
        Subscribers.unsubscribe!
        @original_api_key = EventEngine::Delivery.configuration.cloud_api_key
      end

      teardown do
        Reporter.reset!
        Subscribers.unsubscribe!
        EventEngine::Delivery.configuration.cloud_api_key = @original_api_key
      end

      test "start_reporter! starts reporter and subscribes when cloud_api_key is set" do
        EventEngine::Delivery.configuration.cloud_api_key = "ee_test_abc123"

        EventEngine::Delivery::Engine.send(:start_cloud_reporter!)

        assert Reporter.instance.running?
      end

      test "start_reporter! does nothing when cloud_api_key is nil" do
        EventEngine::Delivery.configuration.cloud_api_key = nil

        EventEngine::Delivery::Engine.send(:start_cloud_reporter!)

        refute Reporter.instance.running?
      end

      test "notifications reach reporter after start_reporter!" do
        EventEngine::Delivery.configuration.cloud_api_key = "ee_test_abc123"

        stub_request(:post, "https://api.eventengine.dev/v1/ingest/events")
          .to_return(status: 202)

        EventEngine::Delivery::Engine.send(:start_cloud_reporter!)

        ActiveSupport::Notifications.instrument("event_engine.event_emitted", {
          event_name: :test_event,
          event_version: 1,
          event_id: 99,
          idempotency_key: "test-key"
        })

        assert_equal 1, Reporter.instance.batch_size
      end
    end
  end
end
