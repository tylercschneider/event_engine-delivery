module EventEngine
  class EventSchemaWriter
    HEADER = <<~RUBY.freeze
      # This file is authoritative in production.
      # It is generated from EventDefinitions via:
      #
      #   bin/rails event_engine:schema:dump
      #
      # Do not edit manually.

    RUBY

    def self.write(path, event_schema)
      schemas =
        event_schema
          .schemas_by_event
          .flat_map { |_event, versions| versions.values }
          .sort_by { |s| [s.event_name.to_s, s.event_version] }

      File.open(path, "w") do |io|
        io.write(HEADER)
        io.write("EventEngine::EventSchema.define do |schema|\n")

        schemas.each do |definition|
          write_definition(io, definition)
        end

        io.write("end\n")
      end
    end

    def self.write_definition(io, definition)
      io.write("  schema.register(\n")
      indent(io, 4) { definition.to_ruby }
      io.write("  )\n")
    end

    def self.indent(io, spaces)
      padding = " " * spaces
      yield.each_line do |line|
        io.write(padding)
        io.write(line)
        io.write("\n")
      end
    end
  end
end
