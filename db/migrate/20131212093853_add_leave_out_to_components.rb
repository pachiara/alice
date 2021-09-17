class AddLeaveOutToComponents < ActiveRecord::Migration
  def change
    add_column :components, :leave_out, :boolean, :default => false
  end
end
