class License < ActiveRecord::Base
  attr_accessible :license_type_id, :category_id, :description, :name, :text_license, :version
  
  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  belongs_to :category
  belongs_to :license_type
  
  has_many   :products
end
