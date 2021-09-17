class ChangeRequiredLicenseToProducts < ActiveRecord::Migration
  def self.up
    remove_column :products, :compatible_license
    add_column    :products, :compatible_license_id, :integer
  end

  def self.down
    remove_column :products, :compatible_license_id
    add_column :products, :compatible_license, :string, :limit => 15
  end
end
