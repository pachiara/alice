class ChangeDescriptionOfLicenses < ActiveRecord::Migration
  def up
    change_column :licenses, :description,        :string,  :limit => 100
  end

  def down
    change_column :licenses, :description,        :string,  :limit => 50
  end
end
