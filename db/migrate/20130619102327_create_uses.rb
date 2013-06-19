class CreateUses < ActiveRecord::Migration
  def change
    create_table :uses do |t|
      t.string :name,         :limit => 5
      t.string :description,  :limit => 100

      t.timestamps
    end
    add_index :uses, [:name], :unique => true
  end
end
