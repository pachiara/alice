class RemoveUseResultCheckedAtFromComponents < ActiveRecord::Migration
  def self.up
    remove_column :components, :use_id
    remove_column :components, :result
    remove_column :components, :checked_at
  end

  def self.down
    add_column :components, :use_id, :integer, :limit => 4
    add_column :components, :result, :boolean, :default => true
    add_column :components, :checked_at, :date
  end
end
