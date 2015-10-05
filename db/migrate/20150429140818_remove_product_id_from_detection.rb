class RemoveProductIdFromDetection < ActiveRecord::Migration
  def self.up
    remove_column :detections, :product_id
  end

  def self.down
    add_column :detections, :product_id,            :integer
  end
end
