namespace :event_engine do
  desc "Fail if event schema DSL has drifted from db/event_schema.rb"
  task schema_check: :environment do
    compiled = EventEngine.compiled_schema_registry
    file = EventEngine.file_schema_registry

    if EventEngine::EventSchemaMerger.changed?(compiled, file)
      raise <<~MSG
        Schema drift detected.

        The compiled EventDefinitions differ from db/event_schema.rb.

        Run:
          bin/rails event_engine:schema:dump

        Then commit the updated schema file.
      MSG
    end
  end
end
