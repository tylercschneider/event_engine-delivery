module EventEngine
  module DefinitionLoader
    class << self
      def ensure_loaded!
        return if loaded?

        unless defined?(Rails) && Rails.application
          raise "EventEngine requires a Rails application to load definitions"
        end

        Rails.application.eager_load!

        @loaded = true
      end

      def loaded?
        @loaded ||= false
      end
    end
  end
end
