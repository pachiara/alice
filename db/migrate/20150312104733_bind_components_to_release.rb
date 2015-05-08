class BindComponentsToRelease < ActiveRecord::Migration
  def up
    Product.all.each do |product|
      product.releases.each do |release|
        components = Component.connection.select_all("SELECT `components`.* FROM `components` INNER JOIN `components_products` ON `components`.`id` = `components_products`.`component_id` WHERE `components_products`.`product_id` = 9")
        components.each do |component|
          execute "INSERT INTO components_releases SET release_id=#{release.id}, component_id=#{component["id"]};"
        end
      end
    end
  end
 
  def down
    execute "DELETE FROM components_releases;"
  end
end
