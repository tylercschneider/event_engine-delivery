class AddPublishedAtToEventEngineOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :event_engine_outbox_events, :published_at, :datetime
  end
end
