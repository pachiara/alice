class BindComponentsToRelease < ActiveRecord::Migration
  def up
    Product.all.each do |product|
      product.releases.each do |release|
        product.components.each do |component|
          execute "INSERT INTO components_releases SET release_id=#{release.id}, component_id=#{component.id};"
        end
      end
    end
  end
 
  def down
    execute "DELETE FROM components_releases;"
  end
end
