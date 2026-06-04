module EventEngine
  class EventSchemaMerger
    def self.merge(compiled_registry, file_registry)
      merged = EventSchema.new

      file_loaded_schema = file_registry.event_schema

      file_loaded_schema.events.each do |event|
        file_loaded_schema.versions_for(event).each do |version|
          merged.register(file_loaded_schema.schema_for(event, version))
        end
      end

      # Merge compiled schemas
      compiled_registry.events.each do |event|
        compiled_schema = compiled_registry.latest_for(event)

        existing_versions = merged.versions_for(event)
        latest_version = existing_versions.max
        latest_schema = latest_version && merged.schema_for(event, latest_version)

        if no_schema_change?(latest_schema, compiled_schema)
          next
        end

        new_version = version(latest_version)
        new_schema = compiled_schema.dup
        new_schema.event_version = new_version

        merged.register(new_schema)
      end

      merged.finalize!

      merged
    end

    def self.changed?(compiled_registry, file_registry)
      compiled_registry.events.any? do |event|
        compiled_schema = compiled_registry.latest_for(event)

        existing_versions = file_registry.versions_for(event)
        latest_version = existing_versions.max
        latest_schema = latest_version && file_registry.schema(event, version: latest_version)

        # New event entirely
        return true unless latest_schema

        # Fingerprint mismatch means a new version would be created
        latest_schema.fingerprint != compiled_schema.fingerprint
      end
    end

    def self.no_schema_change?(latest_schema, compiled_schema)
      latest_schema && latest_schema.fingerprint == compiled_schema.fingerprint
    end

    def self.version(latest_version)
      (latest_version || 0) + 1
    end
  end
end
