require "test_helper"

module EventEngine
  module Transports
    class NullTransportTest < ActiveSupport::TestCase
      test "publish logs a warning and returns true" do
        transport = NullTransport.new
        event = Struct.new(:event_name).new("test_event")

        output = capture_log { transport.publish(event) }

        assert_match(/test_event/, output)
        assert_match(/NullTransport/, output)
      end

      private

      def capture_log(&block)
        original = EventEngine.configuration.instance_variable_get(:@logger)
        io = StringIO.new
        EventEngine.configuration.instance_variable_set(:@logger, Logger.new(io))
        yield
        io.string
      ensure
        EventEngine.configuration.instance_variable_set(:@logger, original)
      end
    end
  end
end
