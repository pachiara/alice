class AddLastReleaseDataToProducts < ActiveRecord::Migration
  def change
    add_column :products, :last_release_checked_at, :date
    add_column :products, :last_release_check_result, :boolean
    add_column :products, :last_release_version_name, :string, :limit => 25
  end
end
