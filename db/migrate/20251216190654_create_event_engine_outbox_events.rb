class CreateEventEngineOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :event_engine_outbox_events do |t|
      t.string :event_name

      t.timestamps
    end
  end
end
