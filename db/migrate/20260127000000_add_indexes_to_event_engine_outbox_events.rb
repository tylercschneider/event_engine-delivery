class AddIndexesToEventEngineOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    add_index :event_engine_outbox_events, :published_at
    add_index :event_engine_outbox_events, :dead_lettered_at
    add_index :event_engine_outbox_events, [:published_at, :dead_lettered_at, :created_at],
              name: "idx_outbox_events_publishable"
  end
end
