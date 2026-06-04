class AddOccurredAtAndMetadataToOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :event_engine_outbox_events, :occurred_at, :datetime, null: false
    add_column :event_engine_outbox_events, :metadata, :json
  end
end
