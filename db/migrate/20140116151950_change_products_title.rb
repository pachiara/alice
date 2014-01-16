class ChangeProductsTitle < ActiveRecord::Migration
  def up
    change_column :products, :title, :string, :limit => 100
  end

  def down
    change_column :products, :title, :string, :limit => 50
  end
end
