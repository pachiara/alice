class BindDetectionsToRelease < ActiveRecord::Migration
  def up
    Detection.all.each do |detection|
      detection.release_id = Product.find(detection.product_id).releases.last.id
      detection.save
    end
  end

  def down
    execute "UPDATE detections SET release_id=0;"
  end

end
