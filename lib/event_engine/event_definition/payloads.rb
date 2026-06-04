module EventEngine
  class EventDefinition
    # DSL methods for declaring payload fields on an event definition.
    module Payloads
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Declares an optional payload field.
        #
        # @param name [Symbol] the field name in the event payload
        # @param from [Symbol] the input to extract the value from
        # @param attr [Symbol, nil] method to call on the input (nil for passthrough)
        def optional_payload(name, from: nil, attr: nil)
          payload_fields << {
            name: name.to_sym,
            required: false,
            from: from,
            attr: attr
          }
        end

        # Declares a required payload field.
        #
        # @param name [Symbol] the field name in the event payload
        # @param from [Symbol] the input to extract the value from
        # @param attr [Symbol, nil] method to call on the input (nil for passthrough)
        def required_payload(name, from: nil, attr: nil)
          payload_fields << {
            name: name.to_sym,
            required: true,
            from: from,
            attr: attr
          }
        end

        # Returns all declared payload field definitions.
        #
        # @return [Array<Hash>]
        def payload_fields
          @payload_fields ||= []
        end
      end
    end
  end
end
