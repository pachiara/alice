class TypeLicense < ActiveRecord::Base
  attr_accessible :code, :description
    
  validates_presence_of :code, :description
  validates_uniqueness_of :code
  
  has_many :licenses
end
