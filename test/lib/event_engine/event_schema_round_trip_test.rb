require "test_helper"
require "tempfile"

class EventSchemaRoundTripTest < ActiveSupport::TestCase
  def build_schema(event_name:, version:)
    EventEngine::EventDefinition::Schema.new(
      event_name: event_name,
      event_version: version,
      event_type: :domain,
      required_inputs: [:cow],
      optional_inputs: [],
      payload_fields: [{ name: :weight, from: :cow, attr: :weight }]
    )
  end

  test "writer and loader round-trip preserves schemas" do
    original = EventEngine::EventSchema.new
    original.register(build_schema(event_name: :cow_fed, version: 1))
    original.register(build_schema(event_name: :cow_fed, version: 2))
    original.register(build_schema(event_name: :pig_fed, version: 1))
    original.finalize!

    file = Tempfile.new("event_schema.rb")

    EventEngine::EventSchemaWriter.write(file.path, original)
    loaded_registry = EventEngine::EventSchemaLoader.load(file.path)
    loaded = loaded_registry.event_schema

    assert_equal original.events.sort, loaded.events.sort
    assert_equal original.versions_for(:cow_fed), loaded.versions_for(:cow_fed)
    assert_equal original.latest_for(:cow_fed).event_version,
                 loaded.latest_for(:cow_fed).event_version
  ensure
    file.unlink
  end
end
