class AddOwnToDetectedComponents < ActiveRecord::Migration
  def change
    add_column :detected_components, :own, :boolean, :default => false
  end
end
