module EventEngine
  # Routes a drained outbox event to its destination based on +process_type+,
  # falling back to the legacy integer +event_level+ when +process_type+ is absent.
  class OutboxRouter
    # Raised when routing an event whose process_type has no supported destination.
    class UnsupportedProcessTypeError < StandardError; end

    # Raised when a :broker event is routed but no transport is configured.
    class MissingTransportError < StandardError; end

    # @param transport [#publish] the broker transport used for :broker events
    def initialize(transport:)
      @transport = transport
    end

    # Dispatches a drained event to its process_type's destination.
    #
    # @param event [OutboxEvent] the drained event
    # @return [void]
    def route(event)
      case process_type_for(event)
      when :durable then notify_subscribers(event)
      when :broker then deliver_to_broker(event)
      when :sourced then raise UnsupportedProcessTypeError, "process_type :sourced (event sourcing) is not supported"
      else publish(event)
      end
    end

    private

    def process_type_for(event)
      (event.process_type || ProcessType.from_event_level(event.event_level))&.to_sym
    end

    def notify_subscribers(record)
      event = Event.from(record)
      EventEngine::Subscribers::Registry.subscribers_for(event.event_name).each do |subscriber|
        subscriber.new.handle(event)
      end
    end

    def deliver_to_broker(event)
      if transport_missing?
        raise MissingTransportError,
              "process_type :broker event '#{event.event_name}' requires a transport, but none is configured"
      end

      publish(event)
    end

    def transport_missing?
      @transport.nil? || (@transport.respond_to?(:null?) && @transport.null?)
    end

    def publish(event)
      @transport.publish(event)
    end
  end
end
