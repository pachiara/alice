class License < ActiveRecord::Base
  attr_accessible :license_type_id, :category_id, :description, :name, :text_license, :version, :flag_osi, :id, :notes
  
  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  belongs_to :category
  belongs_to :license_type
  
  has_many   :products
  
  def self.search(name, page, per_page = 10)
    conditions = sanitize_sql_for_conditions(["name like '%s'", "%#{name}%"])      
    paginate :order => 'name, version', :per_page => per_page, :page => page, :conditions => conditions
  end

# order = 'description ASC', 'description DESC', 'category_id ASC', category_id DESC', 'license_type_id ASC', 'license_type_id DESC'
  def self.search_order(order, page, per_page = 10)
    paginate :order => order, :per_page => per_page, :page => page
  end

end
