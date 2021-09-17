class CreateRuleEntries < ActiveRecord::Migration
  def change
    create_table :rule_entries do |t|
      t.references :rule
      t.integer :license_id
      t.boolean :plus
      t.integer :order

      t.timestamps
    end
    add_index :rule_entries, [:license_id, :order], :unique => true
  end
end
