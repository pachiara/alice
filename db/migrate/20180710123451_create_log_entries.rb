class CreateLogEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :log_entries do |t|
      t.string :user
      t.string :object
      t.string :operation
      t.datetime :date
      t.string :product
      t.string :product_release
      t.string :detection
      t.string :detected_component
      t.string :component
      t.string :version
      t.string :license
      t.string :license_previous
      t.string :license_name_previous
      t.string :similar_license
      t.string :similar_license_previous
      t.string :license_type
      t.string :license_type_previous
      t.boolean :own
      t.boolean :own_previous
      t.boolean :purchased
      t.boolean :purchased_previous
      t.boolean :leave_out
      t.boolean :leave_out_previous
    end
  end
end
