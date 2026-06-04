require "test_helper"
require "tempfile"

class EventSchemaLoaderTest < ActiveSupport::TestCase
  test "loads schemas from event_schema.rb into FileLoadedRegistry" do
    file = Tempfile.new("event_schema.rb")

    file.write <<~RUBY
      EventEngine::EventSchema.define do |schema|
        schema.register(
          EventEngine::EventDefinition::Schema.new(
            event_name: :cow_fed,
            event_version: 1,
            event_type: :domain,
            required_inputs: [:cow],
            optional_inputs: [],
            payload_fields: [{ name: :weight, from: :cow, attr: :weight }]
          )
        )
      end
    RUBY
    file.close

    registry = EventEngine::EventSchemaLoader.load(file.path)

    assert_instance_of EventEngine::SchemaRegistry, registry
    assert_equal [1], registry.versions_for(:cow_fed)
  ensure
    file.unlink
  end

  test "returns empty registry when file does not exist" do
    registry = EventEngine::EventSchemaLoader.load("missing_file.rb")
    assert_equal [], registry.events
  end
end
