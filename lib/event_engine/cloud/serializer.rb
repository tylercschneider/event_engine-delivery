module EventEngine
  module Cloud
    # Converts +ActiveSupport::Notifications+ payloads into metadata-only
    # entries for the Cloud API. Event payloads and PII are never included.
    class Serializer
      # Serializes an event emission notification.
      #
      # @param notification_payload [Hash] the AS::Notifications payload
      # @return [Hash] metadata entry with +:status+ set to +"emitted"+
      def self.serialize_emit(notification_payload)
        {
          event_id: notification_payload[:event_id],
          event_name: notification_payload[:event_name],
          event_version: notification_payload[:event_version],
          idempotency_key: notification_payload[:idempotency_key],
          aggregate_type: notification_payload[:aggregate_type],
          aggregate_id: notification_payload[:aggregate_id],
          aggregate_version: notification_payload[:aggregate_version],
          status: "emitted",
          timestamp: Time.current.iso8601
        }
      end

      # Serializes a publish notification.
      #
      # @param notification_payload [Hash] the AS::Notifications payload
      # @return [Hash] metadata entry with +:status+ set to +"published"+
      def self.serialize_publish(notification_payload)
        {
          event_id: notification_payload[:event_id],
          event_name: notification_payload[:event_name],
          event_version: notification_payload[:event_version],
          status: "published",
          timestamp: Time.current.iso8601
        }
      end

      # Serializes a dead-letter notification. Includes error details.
      #
      # @param notification_payload [Hash] the AS::Notifications payload
      # @return [Hash] metadata entry with +:status+ set to +"dead_lettered"+
      def self.serialize_dead_letter(notification_payload)
        {
          event_id: notification_payload[:event_id],
          event_name: notification_payload[:event_name],
          event_version: notification_payload[:event_version],
          status: "dead_lettered",
          attempts: notification_payload[:attempts],
          error_message: notification_payload[:error_message],
          error_class: notification_payload[:error_class],
          timestamp: Time.current.iso8601
        }
      end
    end
  end
end
