namespace :event_engine do
  namespace :outbox do
    desc "Delete published events older than retention_period"
    task cleanup: :environment do
      retention_period = EventEngine.configuration.retention_period

      unless retention_period
        puts "retention_period not configured. Set config.retention_period in your initializer."
        next
      end

      cutoff = Time.current - retention_period
      events = EventEngine::OutboxEvent.cleanable.published_before(cutoff)
      count = events.count

      if count.zero?
        puts "No events to clean up."
        next
      end

      events.delete_all
      puts "Deleted #{count} event(s) published before #{cutoff}"
    end
  end
end
