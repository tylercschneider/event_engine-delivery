require "test_helper"
require "ostruct"

module EventEngine
  class EventEmitterAggregateTest < ActiveSupport::TestCase
    include EventEngineTestHelpers

    class OrderCreated < EventDefinition
      event_name :order_created
      event_type :domain

      input :order
      required_payload :total, from: :order, attr: :total
    end

    setup do
      @helpers_snapshot = snapshot_event_engine_helpers

      compiled = DslCompiler.compile([OrderCreated])
      compiled.finalize!

      event_schema = EventSchema.new
      compiled.events.each do |event|
        schema = compiled.latest_for(event).dup
        schema.event_version = 1
        event_schema.register(schema)
      end
      event_schema.finalize!

      @registry = SchemaRegistry.new
      @registry.reset!
      @registry.load_from_schema!(event_schema)
    end

    test "emit persists aggregate fields" do
      order = OpenStruct.new(total: 99)

      event = EventEmitter.emit(
        event_name: :order_created,
        data: { order: order },
        registry: @registry,
        aggregate_type: "Order",
        aggregate_id: "order-42",
        aggregate_version: 1
      )

      assert_equal "Order", event.aggregate_type
      assert_equal "order-42", event.aggregate_id
      assert_equal 1, event.aggregate_version
    end

    test "emit works without aggregate fields" do
      order = OpenStruct.new(total: 99)

      event = EventEmitter.emit(
        event_name: :order_created,
        data: { order: order },
        registry: @registry
      )

      assert_nil event.aggregate_type
      assert_nil event.aggregate_id
      assert_nil event.aggregate_version
    end

    teardown do
      restore_event_engine_helpers(@helpers_snapshot)
    end
  end
end
