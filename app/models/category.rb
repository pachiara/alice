class Category < ActiveRecord::Base
  attr_accessible :description, :name
  
  validates_presence_of :name
  validates_uniqueness_of :name
end
