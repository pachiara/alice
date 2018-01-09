class Rule < ApplicationRecord

  belongs_to :license
  has_many :rule_entries, :dependent => :destroy

  validates_presence_of :name, :license_id
end
