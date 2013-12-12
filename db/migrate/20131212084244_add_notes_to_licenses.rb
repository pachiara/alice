class AddNotesToLicenses < ActiveRecord::Migration
  def change
    add_column :licenses, :notes, :text
  end
end
