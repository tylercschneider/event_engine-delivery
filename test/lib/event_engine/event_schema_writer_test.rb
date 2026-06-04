require "test_helper"
require "tempfile"

class EventSchemaWriterTest < ActiveSupport::TestCase
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

  test "writes event_schema.rb with EventSchema.define and registered schemas" do
    es = EventEngine::EventSchema.new
    es.register(build_schema(event_name: :cow_fed, version: 1))
    es.register(build_schema(event_name: :cow_fed, version: 2))
    es.register(build_schema(event_name: :pig_fed, version: 1))
    es.finalize!

    file = Tempfile.new("event_schema.rb")

    EventEngine::EventSchemaWriter.write(file.path, es)

    contents = File.read(file.path)

    assert_includes contents, "EventEngine::EventSchema.define do |schema|"
    assert_equal 3, contents.scan("schema.register(").count
    assert contents.include?("event_name: :cow_fed")
    assert contents.include?("event_version: 2")
    assert contents.include?("event_name: :pig_fed")
  ensure
    file.unlink
  end
end
