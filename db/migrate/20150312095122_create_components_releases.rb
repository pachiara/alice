class CreateComponentsReleases < ActiveRecord::Migration
  def up
    create_table :components_releases, :id => false do |t|
      t.integer :release_id, :null => false
      t.integer :component_id, :null => false
    end  
    add_index :components_releases, [:release_id, :component_id], :unique => true
    add_index :components_releases, [:component_id, :release_id], :unique => true
  end

  def down
    remove_index :components_releases, :column => [:release_id, :component_id]
    remove_index :components_releases, :column => [:component_id, :release_id]
    drop_table :components_releases
  end
end
