require "test_helper"

class EventEngine::InMemoryTransportTest < ActiveSupport::TestCase
  test "stores published events" do
    transport = EventEngine::Transports::InMemoryTransport.new
    event = Object.new

    transport.publish(event)

    assert_equal [event], transport.events
  end
end
