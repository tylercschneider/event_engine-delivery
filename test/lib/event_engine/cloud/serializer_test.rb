require "test_helper"

module EventEngine
  module Cloud
    class SerializerTest < ActiveSupport::TestCase
      test "serialize_emit produces metadata-only entry" do
        notification_payload = {
          event_name: :order_placed,
          event_version: 2,
          event_id: 42,
          idempotency_key: "abc-123"
        }

        entry = Serializer.serialize_emit(notification_payload)

        assert_equal 42, entry[:event_id]
        assert_equal :order_placed, entry[:event_name]
        assert_equal 2, entry[:event_version]
        assert_equal "abc-123", entry[:idempotency_key]
        assert_equal "emitted", entry[:status]
        assert_kind_of String, entry[:timestamp]
        refute entry.key?(:payload)
        refute entry.key?(:metadata)
      end

      test "serialize_publish produces published entry" do
        notification_payload = {
          event_name: :order_placed,
          event_version: 2,
          event_id: 42
        }

        entry = Serializer.serialize_publish(notification_payload)

        assert_equal 42, entry[:event_id]
        assert_equal :order_placed, entry[:event_name]
        assert_equal "published", entry[:status]
        assert_kind_of String, entry[:timestamp]
      end

      test "serialize_dead_letter includes error details" do
        notification_payload = {
          event_name: :order_placed,
          event_version: 1,
          event_id: 42,
          attempts: 5,
          error_message: "Connection refused",
          error_class: "Errno::ECONNREFUSED"
        }

        entry = Serializer.serialize_dead_letter(notification_payload)

        assert_equal 42, entry[:event_id]
        assert_equal "dead_lettered", entry[:status]
        assert_equal 5, entry[:attempts]
        assert_equal "Connection refused", entry[:error_message]
        assert_equal "Errno::ECONNREFUSED", entry[:error_class]
      end
    end
  end
end
