class Product < ActiveRecord::Base
  attr_accessible :checked_at, :description, :license_id, :name, :notes, :result, :title, :use_id, :version
  
  validates_presence_of :name, :title, :use_id
  validates_uniqueness_of :name
  
  belongs_to :use
  belongs_to :license
  
  has_and_belongs_to_many :components
   
  def self.search(name, page)
   conditions = sanitize_sql_for_conditions(["name like '%s'", "%#{name}%"])      
   paginate :order => 'created_at ASC', :per_page => 12, :page => page, :conditions => conditions
  end
  
end
