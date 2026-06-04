module EventEngine
  module Transports
    # Stores published events in memory. Useful for development and testing.
    #
    # @example
    #   transport = EventEngine::Transports::InMemoryTransport.new
    #   transport.publish(event)
    #   transport.events #=> [event]
    class InMemoryTransport
      # @return [Array<OutboxEvent>] all published events
      attr_reader :events

      def initialize
        @events = []
      end

      # Stores the event in the in-memory array.
      #
      # @param event [OutboxEvent]
      # @return [true]
      def publish(event)
        @events << event
        true
      end
    end
  end
end
