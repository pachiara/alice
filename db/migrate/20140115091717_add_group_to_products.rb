class AddGroupToProducts < ActiveRecord::Migration
  def change
        add_column :products, :groupage, :string, :limit => 25
  end
end
