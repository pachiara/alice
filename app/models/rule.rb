class Rule < ActiveRecord::Base
  attr_accessible :name, :license_id, :plus
  
  belongs_to :license
  has_many :rule_entries, :dependent => :destroy
  
  validates_presence_of :name, :license_id  
end
