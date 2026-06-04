require "test_helper"

class EventEngine::DeliveryTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert EventEngine::Delivery::VERSION
  end
end
