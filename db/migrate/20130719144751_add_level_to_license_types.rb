class AddLevelToLicenseTypes < ActiveRecord::Migration
    def self.up
    add_column :license_types, :protection_level, :integer
  end

  def self.down
    remove_column :license_types, :protection_level
  end
  
end
