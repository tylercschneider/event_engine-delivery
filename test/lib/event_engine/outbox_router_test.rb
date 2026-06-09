require "test_helper"

module EventEngine
  class OutboxRouterTest < ActiveSupport::TestCase
    teardown do
      EventEngine::Subscribers::Registry.clear!
    end

    def fake_event(event_name:, process_type: nil, payload: {})
      EventEngine::Event.new(
        event_name: event_name,
        process_type: process_type,
        payload: payload
      )
    end

    test "routes a :durable event to its subscribers" do
      received = []
      Class.new(EventEngine::Subscribers::Base) do
        subscribes_to :cow_milked
        define_method(:handle) { |event| received << event }
      end

      router = OutboxRouter.new(transport: nil)
      router.route(fake_event(event_name: :cow_milked, process_type: :durable))

      assert_equal 1, received.size
    end

    test "routes a :broker event to the broker transport" do
      transport = EventEngine::Transports::InMemoryTransport.new
      event = fake_event(event_name: :sale_processed, process_type: :broker)

      OutboxRouter.new(transport: transport).route(event)

      assert_equal [event], transport.events
    end

    test "raises when a :broker event has no transport configured" do
      event = fake_event(event_name: :sale_processed, process_type: :broker)

      assert_raises(EventEngine::OutboxRouter::MissingTransportError) do
        OutboxRouter.new(transport: nil).route(event)
      end
    end

    test "raises when a :broker event has the null transport" do
      event = fake_event(event_name: :sale_processed, process_type: :broker)

      assert_raises(EventEngine::OutboxRouter::MissingTransportError) do
        OutboxRouter.new(transport: Transports::NullTransport.new).route(event)
      end
    end

    test "raises for an unsupported :sourced event" do
      event = fake_event(event_name: :ledger_entry, process_type: :sourced)

      assert_raises(EventEngine::OutboxRouter::UnsupportedProcessTypeError) do
        OutboxRouter.new(transport: nil).route(event)
      end
    end
  end
end
