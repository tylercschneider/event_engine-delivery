require "test_helper"
require "ostruct"

class EventEmitterVersionFlowTest < ActiveSupport::TestCase
  def build_schema(version:)
    EventEngine::EventDefinition::Schema.new(
      event_name: :cow_fed,
      event_version: version,
      event_type: :domain,
      required_inputs: [:cow],
      optional_inputs: [],
      payload_fields: [{ name: :weight, from: :cow, attr: :weight }]
    )
  end

  setup do
    es = EventEngine::EventSchema.new
    es.register(build_schema(version: 1))
    es.register(build_schema(version: 2))
    es.finalize!

    @registry = EventEngine::SchemaRegistry.new
    @registry.reset!
    @registry.load_from_schema!(es)
  end

  test "emitter persists event_version selected by registry" do
    cow = OpenStruct.new(weight: 500)

    event = EventEngine::EventEmitter.emit(
      event_name: :cow_fed,
      data: { cow: cow },
      version: 1,
      registry: @registry
    )

    assert_equal 1, event.event_version
  end
end
