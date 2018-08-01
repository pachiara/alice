class CreateLogEntriesFromLog < ActiveRecord::Migration[5.2]
  def up
    LogEntry.create_entries_from_log
  end

  def down
    LogEntry.delete_all
  end

end
