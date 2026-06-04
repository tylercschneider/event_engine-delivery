class AddDeadLetteredAtToEventEngineOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :event_engine_outbox_events, :dead_lettered_at, :datetime
  end
end
