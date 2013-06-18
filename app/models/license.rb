class License < ActiveRecord::Base
  attr_accessible :license_type_id, :category_id, :description, :name, :text_license, :version
  
  validates_presence_of :name, :description
  
  belongs_to :category
  belongs_to :license_type
end
