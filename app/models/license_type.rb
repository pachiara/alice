class LicenseType < ActiveRecord::Base
  attr_accessible :id, :code, :description, :protection_level
    
  validates_presence_of :code, :description
  validates_uniqueness_of :code
  
  has_many :licenses
end
