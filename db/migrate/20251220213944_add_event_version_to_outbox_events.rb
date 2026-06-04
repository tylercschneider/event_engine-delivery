class AddEventVersionToOutboxEvents < ActiveRecord::Migration[7.1]
  def up
    # 1. Add column allowing NULLs
    add_column :event_engine_outbox_events, :event_version, :integer

    # 2. Backfill existing rows
    execute <<~SQL
      UPDATE event_engine_outbox_events
      SET event_version = 1
      WHERE event_version IS NULL
    SQL

    # 3. Enforce NOT NULL constraint
    change_column_null :event_engine_outbox_events, :event_version, false
  end

  def down
    remove_column :event_engine_outbox_events, :event_version
  end
end
