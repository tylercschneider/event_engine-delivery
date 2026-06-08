require "test_helper"

module EventEngine
  module Delivery
    class HandlerTest < ActiveSupport::TestCase
      include ActiveJob::TestHelper

      teardown do
        ::EventEngine::SubscriberRegistry.clear!
      end

      def event(process_type: nil, event_level: nil)
        ::EventEngine::Event.new(
          event_name: :cow_fed,
          process_type: process_type,
          event_level: event_level,
          payload: { weight: 1200 }
        )
      end

      test "dispatches an :inline event to subscribers synchronously" do
        received = []
        Class.new(::EventEngine::Subscriber) do
          subscribes_to :cow_fed
          define_method(:handle) { |event| received << event }
        end

        Handler.new.call(event(process_type: :inline))

        assert_equal 1, received.size
      end

      test "enqueues a :background event for asynchronous dispatch" do
        assert_enqueued_with(job: DispatchSubscribersJob) do
          Handler.new.call(event(process_type: :background))
        end
      end

      test "derives dispatch from legacy event_level when process_type is absent" do
        received = []
        Class.new(::EventEngine::Subscriber) do
          subscribes_to :cow_fed
          define_method(:handle) { |event| received << event }
        end

        Handler.new.call(event(event_level: 1))

        assert_equal 1, received.size
      end
    end
  end
end
