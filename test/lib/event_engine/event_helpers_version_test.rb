require "test_helper"
require "ostruct"

module EventEngine
  class EventHelpersVersionTest < ActiveSupport::TestCase
    include EventEngineTestHelpers

    class CowFed < EventDefinition
      event_name :cow_fed
      event_type :domain

      input :cow
      required_payload :weight, from: :cow, attr: :weight
    end

    setup do
      @helpers_snapshot = snapshot_event_engine_helpers
      compiled = DslCompiler.compile([CowFed])
      compiled.finalize!

      es = EventSchema.new
      schema = compiled.latest_for(:cow_fed).dup
      schema.event_version = 1
      es.register(schema)
      es.finalize!

      registry = SchemaRegistry.new

      registry.reset!
      registry.load_from_schema!(es)

      EventEngine.install_helpers(registry: registry)
    end

    test "helper accepts event_version and emits with that version" do
      cow = OpenStruct.new(weight: 500)

      event = EventEngine.cow_fed(cow: cow, event_version: 1)

      assert_equal 1, event.event_version
      assert_equal({ "weight" => 500 }, event.payload)
    end

    test "helper raises on missing required inputs" do
      assert_raises(ArgumentError) do
        EventEngine.cow_fed(event_version: 1)
      end
    end

    teardown do
      restore_event_engine_helpers(@helpers_snapshot)
    end
  end
end
