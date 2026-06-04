class AddConstraintsAndIndexesToEventEngineOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    change_column_null :event_engine_outbox_events, :event_name, false
    add_index :event_engine_outbox_events, :created_at
  end
end
