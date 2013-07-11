class DetectedComponent < ActiveRecord::Base
  belongs_to :detection
  attr_accessible :component_id, :license_id, :license_name, :license_version, :name, :version
  
  validates_presence_of :name, :version
end
