module EventEngine
  module LockingStrategy
    # Returns a locking strategy appropriate for the current database adapter.
    #
    # @return [NullStrategy, PostgresStrategy]
    def self.for_current_adapter
      adapter = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter
      when /postgres/
        PostgresStrategy.new
      else
        NullStrategy.new
      end
    end

    # No-op strategy for adapters that don't support SKIP LOCKED (e.g. SQLite).
    class NullStrategy
      def apply(scope)
        scope
      end
    end

    # Applies FOR UPDATE SKIP LOCKED for PostgreSQL to prevent duplicate
    # deliveries when multiple publisher processes run concurrently.
    class PostgresStrategy
      def apply(scope)
        scope.lock("FOR UPDATE SKIP LOCKED")
      end
    end
  end
end
