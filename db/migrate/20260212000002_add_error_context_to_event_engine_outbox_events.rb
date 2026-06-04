class AddErrorContextToEventEngineOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :event_engine_outbox_events, :last_error_message, :text
    add_column :event_engine_outbox_events, :last_error_class, :string
  end
end
