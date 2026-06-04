class AddAggregateColumnsToEventEngineOutboxEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :event_engine_outbox_events, :aggregate_type, :string
    add_column :event_engine_outbox_events, :aggregate_id, :string
    add_column :event_engine_outbox_events, :aggregate_version, :integer
    add_index :event_engine_outbox_events, [:aggregate_type, :aggregate_id],
      name: "idx_outbox_events_aggregate"
  end
end
