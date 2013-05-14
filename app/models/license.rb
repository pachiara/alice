class License < ActiveRecord::Base
  attr_accessible :category_id, :description, :name, :text_license, :version
  
  validates_presence_of :name, :description
end
