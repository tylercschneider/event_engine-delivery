require "test_helper"

class EventEmitterGuardTest < ActiveSupport::TestCase
  test "raises when emitting before registry is loaded" do
    registry = EventEngine::SchemaRegistry.new
    registry.reset!

    assert_raises(EventEngine::SchemaRegistry::RegistryFrozenError) do
      EventEngine::EventEmitter.emit(
        event_name: :cow_fed,
        data: {},
        registry: registry
      )
    end
  end
end
