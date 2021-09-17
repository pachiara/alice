class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name,                 :limit => 15
      t.string :version,              :limit => 5
      t.string :title,                :limit => 50
      t.text :description

      t.integer :license_id,          :limit => 4
      t.integer :use_id,              :limit => 4
      t.date :checked_at  
      t.boolean :result,              :default => true              
      t.text :notes

      t.timestamps
    end
       
    add_index :products, [:name, :version], :unique => true
    add_index :products, :license_id
    add_index :products, :use_id
    add_index :products, :title

  end
end
