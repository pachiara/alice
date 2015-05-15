class MoveDataFromProductsToReleases < ActiveRecord::Migration
  def up
    Product.all.each do |product|
      if product.version.blank? 
        product.version = 1.0 
      end
      Release.create(
        product_id: product.id,
        version_name: product.version,
        sequential_number: 1.0,
        license_id: product.license_id,
        check_result: product.result,
        checked_at: product.checked_at,
        compatible_license_id: product.compatible_license_id,
        groupage: product.groupage
      )
    end
  end
 
  def down
    Release.delete_all
  end
end
