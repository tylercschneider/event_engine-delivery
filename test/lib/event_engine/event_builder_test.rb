require "test_helper"
require "ostruct"

module EventEngine
  class EventBuilderTest < ActiveSupport::TestCase
    class CowFed < EventDefinition
      event_name :cow_fed
      event_type :domain

      input :cow
      optional_input :farmer

      required_payload :cow_weight, from: :cow, attr: :weight
      optional_payload :farmer_name, from: :farmer, attr: :name
    end

    setup do
      @schema = CowFed.schema
    end

    test "builds payload from schema and data" do
      cow = OpenStruct.new(weight: 500)
      farmer = OpenStruct.new(name: "Bob")

      attrs = EventBuilder.build(
        schema: @schema,
        data: { cow: cow, farmer: farmer }
      )

      assert_equal :cow_fed, attrs[:event_name]
      assert_equal :domain, attrs[:event_type]
      assert_equal({ cow_weight: 500, farmer_name: "Bob" }, attrs[:payload])
    end

    test "raises when required input is missing" do
      cow = OpenStruct.new(weight: 500)

      error = assert_raises(ArgumentError) do
        EventBuilder.build(
          schema: @schema,
          data: { farmer: OpenStruct.new }
        )
      end

      assert_match "missing required input", error.message
    end

    test "raises on unknown input" do
      cow = OpenStruct.new(weight: 500)

      error = assert_raises(ArgumentError) do
        EventBuilder.build(
          schema: @schema,
          data: { cow: cow, extra: Object.new }
        )
      end

      assert_match "unknown input", error.message
    end
  end
end
