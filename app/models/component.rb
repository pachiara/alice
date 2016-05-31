class Component < ActiveRecord::Base
  include Loggable

  attr_accessible :description, :license_id, :name, :notes, :title, :version, :purchased, :own, :leave_out
  
  validates_presence_of :name, :title, :license_id
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
  
  before_update do
    previous = Component.find(id)
    if (license_id != previous.license_id or purchased != previous.purchased or own != previous.own or leave_out != previous.leave_out) then
      alice_logger.info("
        Component: #{name}
        Version: #{version}
        License: #{License.find(license_id).description}
        License previous: #{License.find(previous.license_id).description}          
        Own: #{own}
        Own previous: #{previous.own}
        Purchased: #{purchased}
        Purchased previous: #{previous.purchased}
        Leave_out: #{leave_out}
        Leave_out previous: #{previous.leave_out}
        Updated_by: #{user} ")
    end
  end
  
  before_destroy do
    alice_logger.info("
      Component: #{name}
      Version: #{version}
      License: #{License.find(license_id).description}
      Destroyed_by: #{user} ")
  end

  
end
