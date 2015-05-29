class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.integer :product_id            
      t.string  :version_name,          :limit => 25
      t.decimal :sequential_number,     :precision => 9, :scale => 3
      t.integer :license_id            
      t.boolean :check_result
      t.date    :checked_at
      t.integer :compatible_license_id 
      t.text    :notes

      t.timestamps
    end
  end
end
