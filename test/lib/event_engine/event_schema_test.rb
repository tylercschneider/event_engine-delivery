require "test_helper"

class EventSchemaTest < ActiveSupport::TestCase
  test "register stores schemas by event_name and event_version" do
    schema = EventEngine::EventDefinition::Schema.new(
      event_name: :cow_fed,
      event_version: 1,
      event_type: :domain,
      required_inputs: [:cow],
      optional_inputs: [],
      payload_fields: [{ name: :weight, from: :cow, attr: :weight }]
    )

    event_schema = EventEngine::EventSchema.new
    event_schema.register(schema)

    by_event = event_schema.schemas_by_event

    assert by_event.key?(:cow_fed)
    assert by_event[:cow_fed].key?(1)
    assert_equal schema, by_event[:cow_fed][1]
  end

  test "register supports multiple versions for the same event_name" do
    v1 = EventEngine::EventDefinition::Schema.new(
      event_name: :cow_fed,
      event_version: 1,
      event_type: :domain,
      required_inputs: [:cow],
      optional_inputs: [],
      payload_fields: [{ name: :weight, from: :cow, attr: :weight }]
    )

    v2 = EventEngine::EventDefinition::Schema.new(
      event_name: :cow_fed,
      event_version: 2,
      event_type: :domain,
      required_inputs: [:cow],
      optional_inputs: [],
      payload_fields: [{ name: :age, from: :cow, attr: :age }]
    )

    event_schema = EventEngine::EventSchema.new
    event_schema.register(v1)
    event_schema.register(v2)

    versions = event_schema.schemas_by_event[:cow_fed].keys.sort
    assert_equal [1, 2], versions
  end

  test "register overwrites when registering the same event_name and version" do
    v1a = EventEngine::EventDefinition::Schema.new(
      event_name: :cow_fed,
      event_version: 1,
      event_type: :domain,
      required_inputs: [:cow],
      optional_inputs: [],
      payload_fields: [{ name: :weight, from: :cow, attr: :weight }]
    )

    v1b = EventEngine::EventDefinition::Schema.new(
      event_name: :cow_fed,
      event_version: 1,
      event_type: :domain,
      required_inputs: [:cow],
      optional_inputs: [],
      payload_fields: [{ name: :weight, from: :cow, attr: :weight }]
    )

    event_schema = EventEngine::EventSchema.new
    event_schema.register(v1a)
    event_schema.register(v1b)

    assert_equal v1b, event_schema.schemas_by_event[:cow_fed][1]
  end
end
