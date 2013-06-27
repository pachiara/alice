class Product < ActiveRecord::Base
  attr_accessible :checked_at, :description, :license_id, :name, :notes, :result, :title, :use_id, :version
  
  validates_presence_of :name, :title, :use_id
  validates_uniqueness_of :name
  
  belongs_to :use
  belongs_to :license
  
  has_and_belongs_to_many :components
  
end
