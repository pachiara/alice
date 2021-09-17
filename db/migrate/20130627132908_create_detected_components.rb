class CreateDetectedComponents < ActiveRecord::Migration
  def change
    create_table :detected_components do |t|
      t.references :detection
      t.string :name
      t.string :version
      t.string :license_name
      t.string :license_version
      t.integer :component_id
      t.integer :license_id

      t.timestamps
    end
    add_index :detected_components, :detection_id
  end
end
