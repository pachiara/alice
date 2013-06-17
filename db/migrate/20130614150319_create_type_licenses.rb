class CreateTypeLicenses < ActiveRecord::Migration
  def change
    create_table :type_licenses do |t|
      t.string :code,         :limit => 2
      t.string :description,  :limit => 50
      
      t.timestamps
    end
    add_index :type_licenses, [:code], :unique => true
  end
end
