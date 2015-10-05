class License < ActiveRecord::Base
  attr_accessible :license_type_id, :category_id, :description, :name, :text_license, :version, :flag_osi, :id, :notes, :similar_license_id
  
  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  belongs_to :category
  belongs_to :license_type
  
  has_many   :products
  
  def self.search(name, page, per_page = 10)
    order('name, version').where('name LIKE ?', "%#{name}%").paginate(page: page, per_page: per_page)
  end

  def self.search_order(order, page, per_page = 10)
    order(order).paginate(page: page, per_page: per_page)
  end

end
