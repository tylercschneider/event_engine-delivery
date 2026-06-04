module EventEngine
  class EventDefinition
    # DSL methods for declaring required and optional inputs on an event definition.
    module Inputs
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Declares a required input for this event.
        #
        # @param name [Symbol] the input name
        # @raise [ArgumentError] if the input is already declared
        def input(name)
          name = name.to_sym
          if inputs.key?(name)
            raise ArgumentError, "duplicate input: #{name}"
          end
          inputs[name] = :required
        end

        # Declares an optional input for this event.
        #
        # @param name [Symbol] the input name
        # @raise [ArgumentError] if the input is already declared
        def optional_input(name)
          name = name.to_sym
          if inputs.key?(name)
            raise ArgumentError, "duplicate input: #{name}"
          end
          inputs[name] = :optional
        end

        # Returns all declared inputs as a hash of name => :required/:optional.
        #
        # @return [Hash{Symbol => Symbol}]
        def inputs
          @inputs ||= {}
        end
      end
    end
  end
end
