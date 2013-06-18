class CreateLicenses < ActiveRecord::Migration
  def change
    create_table :licenses do |t|
      t.string :name,                 :limit => 15
      t.string :description,          :limit => 50
      t.string :version,              :limit => 5
      t.integer :category_id,         :limit => 4
      t.integer :license_type_id,     :limit => 4
      t.boolean :flag_osi,            :default => true
      t.text :text_license
  
      t.timestamps
    end
    
    add_index :licenses, [:name, :version], :unique => true
    add_index :licenses, :category_id
    add_index :licenses, :license_type_id
    add_index :licenses, :description
  
  end
end
