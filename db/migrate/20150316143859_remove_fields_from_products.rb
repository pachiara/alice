class RemoveFieldsFromProducts < ActiveRecord::Migration
  def self.up
    remove_column :products, :version
    remove_column :products, :license_id
    remove_column :products, :result
    remove_column :products, :checked_at
    remove_column :products, :compatible_license_id
  end

  def self.down
    add_column :products, :version,               :string,  :limit => 25
    add_column :products, :license_id,            :integer
    add_column :products, :result,                :boolean, :default => nil
    add_column :products, :checked_at,            :date
    add_column :products, :compatible_license_id, :integer
  end
end
