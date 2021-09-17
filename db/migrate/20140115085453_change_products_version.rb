class ChangeProductsVersion < ActiveRecord::Migration
  def up
    change_column :products, :version, :string, :limit => 25
  end

  def down
    change_column :products, :version, :string, :limit => 5
  end
end
