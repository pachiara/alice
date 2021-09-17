class CreateLicenseTypes < ActiveRecord::Migration
  def change
    create_table :license_types do |t|
      t.string :code,         :limit => 2
      t.string :description,  :limit => 50
      
      t.timestamps
    end
    add_index :license_types, [:code], :unique => true
  end
end
