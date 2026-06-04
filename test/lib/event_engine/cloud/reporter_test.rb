require "test_helper"
require "webmock/minitest"

module EventEngine
  module Cloud
    class ReporterTest < ActiveSupport::TestCase
      setup do
        Reporter.reset!
        @original_api_key = EventEngine.configuration.cloud_api_key
        @original_endpoint = EventEngine.configuration.cloud_endpoint
        @original_batch_size = EventEngine.configuration.cloud_batch_size
        @original_flush_interval = EventEngine.configuration.cloud_flush_interval

        EventEngine.configuration.cloud_api_key = "ee_test_abc123"
        EventEngine.configuration.cloud_endpoint = "https://api.eventengine.dev/v1/ingest"
        EventEngine.configuration.cloud_batch_size = 100
        EventEngine.configuration.cloud_flush_interval = 60

        stub_request(:post, "https://api.eventengine.dev/v1/ingest/events")
          .to_return(status: 202, body: '{"received": 0}')
        stub_request(:post, "https://api.eventengine.dev/v1/ingest/heartbeat")
          .to_return(status: 200)
      end

      teardown do
        Reporter.reset!
        EventEngine.configuration.cloud_api_key = @original_api_key
        EventEngine.configuration.cloud_endpoint = @original_endpoint
        EventEngine.configuration.cloud_batch_size = @original_batch_size
        EventEngine.configuration.cloud_flush_interval = @original_flush_interval
      end

      test "instance returns singleton" do
        assert_same Reporter.instance, Reporter.instance
      end

      test "start sets running state" do
        reporter = Reporter.instance
        refute reporter.running?

        reporter.start
        assert reporter.running?
      end

      test "shutdown stops the reporter" do
        reporter = Reporter.instance
        reporter.start
        assert reporter.running?

        reporter.shutdown
        refute reporter.running?
      end

      test "track_emit pushes entry to batch" do
        reporter = Reporter.instance
        reporter.start

        reporter.track_emit({ event_id: 1, event_name: :test, status: "emitted" })

        assert_equal 1, reporter.batch_size
      end

      test "flush sends batch to API when entries exist" do
        reporter = Reporter.instance
        reporter.start

        reporter.track_emit({ event_id: 1, event_name: :test, status: "emitted" })
        reporter.flush

        assert_requested(:post, "https://api.eventengine.dev/v1/ingest/events")
        assert_equal 0, reporter.batch_size
      end

      test "flush does nothing when batch is empty" do
        reporter = Reporter.instance
        reporter.start

        reporter.flush

        assert_not_requested(:post, "https://api.eventengine.dev/v1/ingest/events")
      end

      test "auto-flushes when batch reaches max size" do
        EventEngine.configuration.cloud_batch_size = 3
        Reporter.reset!
        reporter = Reporter.instance
        reporter.start

        reporter.track_emit({ event_id: 1, event_name: :test, status: "emitted" })
        reporter.track_emit({ event_id: 2, event_name: :test, status: "emitted" })
        reporter.track_emit({ event_id: 3, event_name: :test, status: "emitted" })

        assert_requested(:post, "https://api.eventengine.dev/v1/ingest/events")
        assert_equal 0, reporter.batch_size
      end

      test "shutdown flushes remaining entries" do
        reporter = Reporter.instance
        reporter.start

        reporter.track_emit({ event_id: 1, event_name: :test, status: "emitted" })
        reporter.shutdown

        assert_requested(:post, "https://api.eventengine.dev/v1/ingest/events")
      end

      test "track_publish pushes entry to batch" do
        reporter = Reporter.instance
        reporter.start

        reporter.track_publish({ event_id: 1, event_name: :test, status: "published" })

        assert_equal 1, reporter.batch_size
      end

      test "track_dead_letter pushes entry to batch" do
        reporter = Reporter.instance
        reporter.start

        reporter.track_dead_letter({ event_id: 1, event_name: :test, status: "dead_lettered" })

        assert_equal 1, reporter.batch_size
      end

      test "start logs reporter started message" do
        log = StringIO.new
        EventEngine.configuration.logger = Logger.new(log)

        reporter = Reporter.instance
        reporter.start

        assert_match(/Cloud Reporter started/, log.string)
        assert_match(/api\.eventengine\.dev/, log.string)
      ensure
        EventEngine.configuration.logger = Logger.new($stdout)
      end

      test "shutdown logs reporter stopped message" do
        log = StringIO.new
        EventEngine.configuration.logger = Logger.new(log)

        reporter = Reporter.instance
        reporter.start
        reporter.shutdown

        assert_match(/Cloud Reporter stopped/, log.string)
      ensure
        EventEngine.configuration.logger = Logger.new($stdout)
      end

      test "start spawns a timer thread and shutdown stops it" do
        reporter = Reporter.instance
        reporter.start

        timer = reporter.instance_variable_get(:@timer_thread)
        assert timer, "Expected @timer_thread to be set"
        assert timer.alive?, "Expected timer thread to be alive after start"

        reporter.shutdown

        refute timer.alive?, "Expected timer thread to be dead after shutdown"
      end

      test "timer periodically flushes entries" do
        EventEngine.configuration.cloud_flush_interval = 0.1
        Reporter.reset!
        reporter = Reporter.instance
        reporter.start

        reporter.track_emit({ event_id: 1, event_name: :test, status: "emitted" })
        sleep(0.25)

        assert_requested(:post, "https://api.eventengine.dev/v1/ingest/events")
        assert_equal 0, reporter.batch_size
      end

      test "timer rescues errors during flush and keeps running" do
        stub_request(:post, "https://api.eventengine.dev/v1/ingest/events")
          .to_raise(StandardError.new("connection refused"))

        EventEngine.configuration.cloud_flush_interval = 0.1
        Reporter.reset!
        reporter = Reporter.instance
        reporter.start

        reporter.track_emit({ event_id: 1, event_name: :test, status: "emitted" })
        sleep(0.25)

        assert reporter.running?, "Expected reporter to still be running after flush error"

        timer = reporter.instance_variable_get(:@timer_thread)
        assert timer.alive?, "Expected timer thread to still be alive after flush error"

        reporter.track_emit({ event_id: 2, event_name: :test, status: "emitted" })
        assert_operator reporter.batch_size, :>=, 1, "Expected reporter to still accept entries"
      end
    end
  end
end
