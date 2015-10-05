class AddReleaseIdToDetections < ActiveRecord::Migration
  def change
    add_column :detections, :release_id, :integer
  end
end
