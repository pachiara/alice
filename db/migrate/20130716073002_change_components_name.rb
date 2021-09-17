class ChangeComponentsName < ActiveRecord::Migration
  def up 
    change_column :components, :name, :string, :limit => 30
  end
  def down 
    change_column :components, :name, :string, :limit => 15
  end
end
