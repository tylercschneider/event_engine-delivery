require "test_helper"

module EventEngine
  class SubscriberRegistryTest < ActiveSupport::TestCase
    class FakeSubscriber; end

    teardown do
      SubscriberRegistry.clear!
    end

    test "registers a subscriber retrievable by event name" do
      SubscriberRegistry.register(:cow_fed, FakeSubscriber)

      assert_includes SubscriberRegistry.subscribers_for(:cow_fed), FakeSubscriber
    end

    test "returns an empty array for an event with no subscribers" do
      assert_equal [], SubscriberRegistry.subscribers_for(:never_registered)
    end
  end
end
