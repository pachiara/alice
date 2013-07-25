class LicenseType < ActiveRecord::Base
  attr_accessible :code, :description, :protection_level
    
  validates_presence_of :code, :description, :protection_level
  validates_uniqueness_of :code
  
  has_many :licenses
end
