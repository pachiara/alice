class ChangeProductsName2 < ActiveRecord::Migration[5.2]
  def up
    change_column :products, :name, :string, :limit => 32
  end

  def down
    change_column :products, :name, :string, :limit => 30
  end
end
