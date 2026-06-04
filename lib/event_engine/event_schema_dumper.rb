module EventEngine
  class EventSchemaDumper
    def self.dump!(definitions:, path:)
      compiled_schema = DslCompiler.compile(definitions)
      compiled_schema.finalize!

      loaded_schema = EventSchemaLoader.load(path)
      merged_schema = EventSchemaMerger.merge(compiled_schema, loaded_schema)

      EventSchemaWriter.write(path, merged_schema)
    end
  end
end
