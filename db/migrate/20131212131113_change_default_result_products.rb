class ChangeDefaultResultProducts < ActiveRecord::Migration
  def up
    change_column :products, :result, :boolean, :default => nil
  end

  def down
    change_column :products, :result, :boolean, :default => true
  end
end
