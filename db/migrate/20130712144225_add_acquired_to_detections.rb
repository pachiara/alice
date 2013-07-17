class AddAcquiredToDetections < ActiveRecord::Migration
  def self.up
    add_column :detections, :acquired, :boolean, :default => false
  end

  def self.down
    remove_column :detections, :acquired
  end
end
