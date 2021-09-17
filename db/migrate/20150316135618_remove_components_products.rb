class RemoveComponentsProducts < ActiveRecord::Migration
  def up
    remove_index :components_products, :column => [:product_id, :component_id]
    remove_index :components_products, :column => [:component_id, :product_id]
    drop_table :components_products
  end
  

  def down
    create_table :components_products, :id => false do |t|
      t.integer :product_id, :null => false
      t.integer :component_id, :null => false
    end  
    add_index :components_products, [:product_id, :component_id], :unique => true
    add_index :components_products, [:component_id, :product_id], :unique => true
  end
end
