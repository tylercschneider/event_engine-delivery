require "test_helper"
require "ostruct"

module EventEngine
  class EventDefinitionPassthroughPayloadTest < ActiveSupport::TestCase
    class UserDefinedEvent < EventDefinition
      event_name :user_defined_event
      event_type :domain

      input :account
      input :event_type_name
      input :payload

      required_payload :account_id, from: :account, attr: :id
      required_payload :event_type_name, from: :event_type_name
      required_payload :payload, from: :payload
    end

    test "passthrough payload uses input value directly when attr is omitted" do
      account = OpenStruct.new(id: 123)

      attrs = EventBuilder.build(
        schema: UserDefinedEvent.schema,
        data: {
          account: account,
          event_type_name: "custom_event",
          payload: { foo: "bar", count: 42 }
        }
      )

      assert_equal 123, attrs[:payload][:account_id]
      assert_equal "custom_event", attrs[:payload][:event_type_name]
      assert_equal({ foo: "bar", count: 42 }, attrs[:payload][:payload])
    end

    test "schema is valid without attr when from references simple value input" do
      assert UserDefinedEvent.valid_schema?
    end
  end
end
