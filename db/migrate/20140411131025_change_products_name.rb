class ChangeProductsName < ActiveRecord::Migration
  def up
        change_column :products, :name, :string, :limit => 30
  end

  def down
    change_column :products, :name, :string, :limit => 15
  end
end
