class ChangeComponentsVersion < ActiveRecord::Migration
  def up 
    change_column :components, :version, :string, :limit => 25
  end
  def down 
    change_column :components, :version, :string, :limit => 5
  end
end
