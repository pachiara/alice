class AddParsedFileFieldsToDetections < ActiveRecord::Migration[5.2]
  def change
    add_column :detections, :parsed_file_name, :string
    add_column :detections, :parsed_file_at, :datetime
  end
end
