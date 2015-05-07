class Component < ActiveRecord::Base
  attr_accessible :checked_at, :description, :license_id, :name, :notes, :result, :title, :use_id, :version, :purchased, :own, :leave_out
  
  validates_presence_of :name, :title, :use_id, :license_id
  validates :version, :uniqueness => {:scope => [:name]}
  validate  :purchase_or_own
  
  belongs_to :use
  belongs_to :license
    
  has_and_belongs_to_many :releases
  
  def self.search(name, page, per_page = 10)
   order('name, version').where('name LIKE ?', "%#{name}%").paginate(page: page, per_page: per_page)   
  end
  
  def purchase_or_own
    if purchased and own
      errors.add(:purchased, "valori imcompatibili")
      errors.add(:own, "")
    end
  end
  
end
