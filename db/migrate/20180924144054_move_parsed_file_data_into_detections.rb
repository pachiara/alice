class MoveParsedFileDataIntoDetections < ActiveRecord::Migration[5.2]
  def up
    Detection.all.each do |detection|
      detection.parsed_file_name = detection.xml_file_name
      detection.parsed_file_at = detection.xml_updated_at
      detection.save 
    end
    remove_attachment :detections, :xml
  end
 
  def down
    add_attachment :detections, :xml
    Detection.all.each do |detection|
      detection.xml_file_name = detection.parsed_file_name
      detection.xml_updated_at = detection.parsed_file_at
      detection.xml_content_type = "application/xml"
      detection.xml_file_size = 1
      detection.save 
    end
    execute "update detections set parsed_file_name=NULL, parsed_file_at=NULL;"
  end
end
