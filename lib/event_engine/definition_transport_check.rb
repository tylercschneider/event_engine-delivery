module EventEngine
  # Inspects loaded event definitions at boot and logs a non-blocking warning
  # when a :broker event exists but no real transport is configured (a :broker
  # event publishes to a broker, so it needs one). This is a soft, early signal;
  # the hard failure happens at runtime in {OutboxRouter} when such an event is
  # actually drained.
  module DefinitionTransportCheck
    # @param registry [SchemaRegistry] the loaded registry
    # @param transport [#publish, nil] the configured transport
    # @param logger [Logger] where to write the warning
    # @return [void]
    def self.run(registry:, transport:, logger:)
      return if real_transport?(transport)

      broker = registry.events.select { |name| registry.schema(name).process_type == :broker }
      return if broker.empty?

      logger.warn(
        "[EventEngine] No transport configured, but these :broker events require one: " \
        "#{broker.join(', ')}. They will raise when published. Set config.transport."
      )
    end

    def self.real_transport?(transport)
      !transport.nil? && !(transport.respond_to?(:null?) && transport.null?)
    end
    private_class_method :real_transport?
  end
end
