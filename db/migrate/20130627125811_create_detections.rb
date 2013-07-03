class CreateDetections < ActiveRecord::Migration
  def change
    create_table :detections do |t|
      t.string :name
      t.integer :product_id

      t.timestamps
    end
    add_attachment :detections, :xml
  end
end
