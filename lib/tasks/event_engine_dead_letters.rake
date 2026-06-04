namespace :event_engine do
  namespace :dead_letters do
    desc "List all dead-lettered events"
    task list: :environment do
      events = EventEngine::OutboxEvent.dead_lettered.ordered

      if events.empty?
        puts "No dead-lettered events found."
        next
      end

      puts "Dead-lettered events:"
      puts "-" * 80
      printf "%-10s %-30s %-10s %-20s\n", "ID", "Event Name", "Attempts", "Dead Lettered At"
      puts "-" * 80

      events.each do |event|
        printf "%-10s %-30s %-10s %-20s\n",
          event.id,
          event.event_name.truncate(30),
          event.attempts,
          event.dead_lettered_at.strftime("%Y-%m-%d %H:%M:%S")
      end

      puts "-" * 80
      puts "Total: #{events.count} event(s)"
    end

    desc "Retry a dead-lettered event by ID"
    task :retry, [:event_id] => :environment do |_t, args|
      event_id = args[:event_id]

      unless event_id
        puts "Usage: rake event_engine:dead_letters:retry[EVENT_ID]"
        next
      end

      event = EventEngine::OutboxEvent.dead_lettered.find_by(id: event_id)

      unless event
        puts "No dead-lettered event found with ID #{event_id}"
        next
      end

      event.retry!
      puts "Retried 1 event (ID: #{event.id})"
    end

    namespace :retry do
      desc "Retry all dead-lettered events"
      task all: :environment do
        events = EventEngine::OutboxEvent.dead_lettered
        count = events.count

        if count.zero?
          puts "No dead-lettered events to retry."
          next
        end

        events.find_each(&:retry!)
        puts "Retried #{count} event(s)"
      end
    end
  end
end
