class AddIdempotencyKeyToEventEngineOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :event_engine_outbox_events, :idempotency_key, :string
    add_index  :event_engine_outbox_events, :idempotency_key, unique: true
  end
end
