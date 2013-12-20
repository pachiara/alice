class AddSimilarLicenseIdToLicenses < ActiveRecord::Migration
  def change
    add_column :licenses, :similar_license_id, :integer
  end
end
