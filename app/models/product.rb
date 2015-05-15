class Product < ActiveRecord::Base
  attr_accessible :description, :name, :notes, :title, :use_id
  
  validates_presence_of :name, :title, :use_id
  validates_uniqueness_of :name
  
  belongs_to :use
  has_many :releases, :dependent => :destroy
  
  def last_release
    return self.releases.order("sequential_number").last
  end
  
  def self.search(name, groupage, page, per_page = 10)
#   order('name').where('name LIKE ? and groupage LIKE ?', "%#{name}%","%#{groupage}%").paginate(page: page, per_page: per_page)
   order('name').where('name LIKE ?', "%#{name}%").paginate(page: page, per_page: per_page)
  end
  
  def self.search_order(order, page, per_page = 10)
    order(order).paginate(page: page, per_page: per_page)
  end
  
end
