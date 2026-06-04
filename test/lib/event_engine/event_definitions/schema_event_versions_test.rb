require "test_helper"

class SchemaEventVersionTest < ActiveSupport::TestCase
  test "schema allows event_version to be nil at construction" do
    schema = EventEngine::EventDefinition::Schema.new(
      event_name: :cow_fed,
      event_version: nil,
      event_type: :domain,
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    assert_nil schema.event_version
  end

  test "event_schema_merger assigns initial event_version when none exists" do
    # file-loaded schema is empty (no prior versions)
    file_schema = EventEngine::EventSchema.new
    file_schema.finalize!
    file_registry = EventEngine::SchemaRegistry.new(file_schema)

    # compiled schema has no version
    compiled_schema = EventEngine::EventDefinition::Schema.new(
      event_name: :cow_fed,
      event_version: nil,
      event_type: :domain,
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    compiled = EventEngine::SchemaRegistry.new
    compiled.register(compiled_schema)
    compiled.finalize!

    merged = EventEngine::EventSchemaMerger.merge(compiled, file_registry)

    loaded = merged.latest_for(:cow_fed)

    assert_equal 1, loaded.event_version
  end
end
