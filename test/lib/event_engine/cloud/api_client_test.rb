require "test_helper"
require "webmock/minitest"

module EventEngine
  module Cloud
    class ApiClientTest < ActiveSupport::TestCase
      setup do
        @client = ApiClient.new(
          api_key: "ee_test_abc123",
          endpoint: "https://api.eventengine.dev/v1/ingest"
        )
      end

      test "send_batch posts entries to /events endpoint" do
        stub = stub_request(:post, "https://api.eventengine.dev/v1/ingest/events")
          .with(
            headers: {
              "Authorization" => "Bearer ee_test_abc123",
              "Content-Type" => "application/json",
              "X-EventEngine-Gem-Version" => EventEngine::VERSION
            }
          )
          .to_return(status: 202, body: '{"received": 1}')

        entries = [{ event_id: 1, event_name: "order.placed", status: "emitted" }]
        result = @client.send_batch(entries)

        assert_requested(stub)
        assert_equal true, result
      end

      test "send_batch returns false on network error" do
        stub_request(:post, "https://api.eventengine.dev/v1/ingest/events")
          .to_raise(Errno::ECONNREFUSED)

        entries = [{ event_id: 1 }]
        result = @client.send_batch(entries)

        assert_equal false, result
      end

      test "send_batch returns false on non-2xx response" do
        stub_request(:post, "https://api.eventengine.dev/v1/ingest/events")
          .to_return(status: 500, body: "Internal Server Error")

        entries = [{ event_id: 1 }]
        result = @client.send_batch(entries)

        assert_equal false, result
      end

      test "send_heartbeat posts to /heartbeat endpoint" do
        stub = stub_request(:post, "https://api.eventengine.dev/v1/ingest/heartbeat")
          .with(
            headers: { "Authorization" => "Bearer ee_test_abc123" }
          )
          .to_return(status: 200)

        heartbeat = { app_name: "MyApp", environment: "production" }
        result = @client.send_heartbeat(heartbeat)

        assert_requested(stub)
        assert_equal true, result
      end

      test "send_heartbeat returns false on network error" do
        stub_request(:post, "https://api.eventengine.dev/v1/ingest/heartbeat")
          .to_raise(Timeout::Error)

        result = @client.send_heartbeat({ app_name: "MyApp" })

        assert_equal false, result
      end
    end
  end
end
