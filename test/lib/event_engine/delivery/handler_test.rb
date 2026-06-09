require "test_helper"

module EventEngine
  module Delivery
    class HandlerTest < ActiveSupport::TestCase
      include ActiveJob::TestHelper

      teardown do
        ::EventEngine::Subscribers::Registry.clear!
      end

      def event(process_type: nil, event_level: nil)
        ::EventEngine::Event.new(
          event_name: :cow_fed,
          process_type: process_type,
          event_level: event_level,
          payload: { weight: 1200 }
        )
      end

      test "does not run subscribers for an :inline event (left to event_engine-subscribers)" do
        received = []
        Class.new(::EventEngine::Subscribers::Base) do
          subscribes_to :cow_fed
          define_method(:handle) { |event| received << event }
        end

        Handler.new.call(event(process_type: :inline))

        assert_empty received
      end

      test "does not enqueue a job for a :background event (left to event_engine-subscribers)" do
        assert_no_enqueued_jobs do
          Handler.new.call(event(process_type: :background))
        end
      end
    end
  end
end
