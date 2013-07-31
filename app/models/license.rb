class License < ActiveRecord::Base
  attr_accessible :license_type_id, :category_id, :description, :name, :text_license, :version, :flag_osi
  
  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  belongs_to :category
  belongs_to :license_type
  
  has_many   :products
  
  def self.search(name, page, per_page = 12)
    conditions = sanitize_sql_for_conditions(["name like '%s'", "%#{name}%"])      
    paginate :order => 'created_at ASC', :per_page => per_page, :page => page, :conditions => conditions
  end
end
