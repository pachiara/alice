class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.string  :name
      t.integer :license_id
      t.boolean :plus

      t.timestamps
    end
    add_index :rules, :license_id
  end
end
