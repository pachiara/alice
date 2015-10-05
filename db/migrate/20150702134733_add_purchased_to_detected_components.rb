class AddPurchasedToDetectedComponents < ActiveRecord::Migration
  def change
    add_column :detected_components, :purchased, :boolean, :default => false
  end
end
