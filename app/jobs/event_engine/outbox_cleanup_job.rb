module EventEngine
  class OutboxCleanupJob < ApplicationJob
    queue_as :default

    def perform
      retention_period = EventEngine.configuration.retention_period
      return unless retention_period

      cutoff = Time.current - retention_period
      OutboxEvent.cleanable.published_before(cutoff).delete_all
    end
  end
end
