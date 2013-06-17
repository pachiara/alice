class License < ActiveRecord::Base
  attr_accessible :type_license_id, :category_id, :description, :name, :text_license, :version
  
  validates_presence_of :name, :description
  
  belongs_to :category
  belongs_to :type_license
end
