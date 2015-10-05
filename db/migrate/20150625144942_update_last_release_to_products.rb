class UpdateLastReleaseToProducts < ActiveRecord::Migration
  def change
    Product.all.each do |product|
      product.update_last_release
      product.save
    end
  end
end
