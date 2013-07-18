class RuleEntry < ActiveRecord::Base
  belongs_to :rule
  attr_accessible :license_id, :order, :plus
  
  belongs_to :license
  validates_presence_of :license_id, :order
end
