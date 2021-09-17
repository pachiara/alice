class ChangeComponentsNameTo50 < ActiveRecord::Migration
  def up
    change_column :components, :name, :string, :limit => 50
  end

  def down
    change_column :components, :name, :string, :limit => 30
  end
end