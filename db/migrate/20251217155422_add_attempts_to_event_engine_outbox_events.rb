class AddAttemptsToEventEngineOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :event_engine_outbox_events, :attempts, :integer, null: false, default: 0
  end
end
