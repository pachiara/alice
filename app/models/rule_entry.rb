class RuleEntry < ApplicationRecord

  belongs_to :rule
  belongs_to :license

  validates_presence_of :license_id, :order_id

end
