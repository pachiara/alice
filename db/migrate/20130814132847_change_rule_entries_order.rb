class ChangeRuleEntriesOrder < ActiveRecord::Migration
  def up
    rename_column :rule_entries, :order, :order_id
    add_index :rule_entries, [:order_id]
  end

  def down
    remove_index :rule_entries, [:order_id]
    rename_column :rule_entries, :order_id, :order
  end
end
