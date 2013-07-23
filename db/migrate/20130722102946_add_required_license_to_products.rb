class AddRequiredLicenseToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :compatible_license, :string, :limit => 15
  end

  def self.down
    remove_column :products, :compatible_license
  end
  
end
