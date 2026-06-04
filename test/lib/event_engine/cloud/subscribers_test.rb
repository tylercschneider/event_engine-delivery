require "test_helper"

module EventEngine
  module Cloud
    class SubscribersTest < ActiveSupport::TestCase
      setup do
        @tracked = []
      end

      teardown do
        Subscribers.unsubscribe!
      end

      test "subscribes to event_emitted and calls track_emit" do
        called_with = nil
        Subscribers.subscribe!(reporter: FakeReporter.new(on_emit: ->(p) { called_with = p }))

        ActiveSupport::Notifications.instrument("event_engine.event_emitted", {
          event_name: :order_placed,
          event_version: 1,
          event_id: 42,
          idempotency_key: "abc"
        })

        assert_equal :order_placed, called_with[:event_name]
        assert_equal 42, called_with[:event_id]
      end

      test "subscribes to event_published and calls track_publish" do
        called_with = nil
        Subscribers.subscribe!(reporter: FakeReporter.new(on_publish: ->(p) { called_with = p }))

        ActiveSupport::Notifications.instrument("event_engine.event_published", {
          event_name: :order_placed,
          event_version: 1,
          event_id: 42
        })

        assert_equal :order_placed, called_with[:event_name]
        assert_equal "published", called_with[:status]
      end

      test "subscribes to event_dead_lettered and calls track_dead_letter" do
        called_with = nil
        Subscribers.subscribe!(reporter: FakeReporter.new(on_dead_letter: ->(p) { called_with = p }))

        ActiveSupport::Notifications.instrument("event_engine.event_dead_lettered", {
          event_name: :order_placed,
          event_version: 1,
          event_id: 42,
          attempts: 5,
          error_message: "timeout",
          error_class: "Timeout::Error"
        })

        assert_equal :order_placed, called_with[:event_name]
        assert_equal "dead_lettered", called_with[:status]
        assert_equal 5, called_with[:attempts]
      end

      test "unsubscribe! stops receiving notifications" do
        call_count = 0
        Subscribers.subscribe!(reporter: FakeReporter.new(on_emit: ->(_) { call_count += 1 }))

        ActiveSupport::Notifications.instrument("event_engine.event_emitted", { event_name: :test })
        assert_equal 1, call_count

        Subscribers.unsubscribe!

        ActiveSupport::Notifications.instrument("event_engine.event_emitted", { event_name: :test })
        assert_equal 1, call_count
      end

      class FakeReporter
        def initialize(on_emit: nil, on_publish: nil, on_dead_letter: nil)
          @on_emit = on_emit
          @on_publish = on_publish
          @on_dead_letter = on_dead_letter
        end

        def track_emit(entry)
          @on_emit&.call(entry)
        end

        def track_publish(entry)
          @on_publish&.call(entry)
        end

        def track_dead_letter(entry)
          @on_dead_letter&.call(entry)
        end
      end
    end
  end
end
