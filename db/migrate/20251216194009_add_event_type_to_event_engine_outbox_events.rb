class AddEventTypeToEventEngineOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :event_engine_outbox_events, :event_type, :string, null: false
  end
end
