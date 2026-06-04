module EventEngine
  class EventSchemaLoader
    def self.load(path)
      registry = SchemaRegistry.new
      return registry unless File.exist?(path)

      contents = File.read(path.to_s)
      return registry if contents.strip.empty?

      sandbox = Module.new
      sandbox.const_set(:EventEngine, EventEngine)

      schema =
        sandbox.module_eval(contents, path.to_s)

      unless schema.is_a?(EventEngine::EventSchema)
        raise <<~MSG
          Invalid EventEngine schema file.

          Expected #{path} to return an EventSchema from:
            EventEngine::EventSchema.define { ... }

          But got:
            #{schema.inspect}
        MSG
      end

      schema.schemas_by_event.each_value do |versions|
        versions.each_value do |s|
          registry.register(s)
        end
      end

      registry
    end
  end
end
