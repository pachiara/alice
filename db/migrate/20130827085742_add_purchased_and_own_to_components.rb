class AddPurchasedAndOwnToComponents < ActiveRecord::Migration
  def self.up
    add_column :components, :purchased, :boolean, :default => false
    add_column :components, :own, :boolean, :default => false
  end

  def self.down
    remove_column :components, :purchased
    remove_column :components, :own
  end

end