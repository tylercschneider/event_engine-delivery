class AddPayloadToEventEngineOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    if connection.adapter_name.downcase.include?("postgres")
      add_column :event_engine_outbox_events, :payload, :jsonb, null: false
    else
      add_column :event_engine_outbox_events, :payload, :json, null: false
    end
  end
end
