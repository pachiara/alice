class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name,         :limit => 15
      t.string :description,  :limit => 50

      t.timestamps
    end
    add_index :categories, [:name], :unique => true
  end
end
