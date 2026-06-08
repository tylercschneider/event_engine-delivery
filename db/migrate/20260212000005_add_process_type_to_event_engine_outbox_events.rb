class AddProcessTypeToEventEngineOutboxEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :event_engine_outbox_events, :process_type, :string
  end
end
