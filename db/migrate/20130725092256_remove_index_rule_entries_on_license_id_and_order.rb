class RemoveIndexRuleEntriesOnLicenseIdAndOrder < ActiveRecord::Migration
  def up
        remove_index :rule_entries, [:license_id, :order]
  end

  def down
        add_index :rule_entries, [:license_id, :order], :unique => true
  end
end
