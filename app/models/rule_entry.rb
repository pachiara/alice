class RuleEntry < ActiveRecord::Base
  attr_accessible :license_id, :order, :plus
  
  belongs_to :rule
  belongs_to :license

  validates_presence_of :license_id, :order
end
