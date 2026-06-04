require "test_helper"
require "ostruct"

class EventMetadataAndOccurredAtTest < ActiveSupport::TestCase
  include EventEngineTestHelpers

  class CowFed < EventEngine::EventDefinition
    event_name :cow_fed
    event_type :domain
    input :cow
    required_payload :weight, from: :cow, attr: :weight
  end

  setup do
    @helpers_snapshot = snapshot_event_engine_helpers

    compiled = EventEngine::DslCompiler.compile([CowFed])
    compiled.finalize!

    schema = compiled.latest_for(:cow_fed)
    schema.event_version = 1

    event_schema = EventEngine::EventSchema.new
    event_schema.register(schema)
    event_schema.finalize!

    registry = EventEngine::SchemaRegistry.new
    registry.reset!
    registry.load_from_schema!(event_schema)

    EventEngine.install_helpers(registry: registry)
  end

  test "occurred_at and metadata are persisted on outbox event" do
    cow = OpenStruct.new(weight: 500)
    occurred_at = Time.utc(2025, 1, 1, 12, 0, 0)
    metadata = {
      request_id: "req_123",
      source: "api"
    }

    event = EventEngine.cow_fed(
      cow: cow,
      occurred_at: occurred_at,
      metadata: metadata
    )

    assert_equal occurred_at, event.occurred_at
    assert_equal metadata.stringify_keys, event.metadata
  end

  teardown do
    restore_event_engine_helpers(@helpers_snapshot)
  end
end
