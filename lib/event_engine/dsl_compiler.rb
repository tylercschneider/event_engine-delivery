module EventEngine
  class DslCompiler
    def self.compile(definitions)
      registry = SchemaRegistry.new

      Array(definitions).each do |definition|
        schema = definition.schema
        registry.register(schema)
      end

      registry
    end
  end
end
