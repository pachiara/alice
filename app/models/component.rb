class Component < ActiveRecord::Base
  attr_accessible :checked_at, :description, :license_id, :name, :notes, :result, :title, :use_id, :version
  
  validates_presence_of :name, :title, :use_id
  validates :version, :uniqueness => {:scope => [:name]}
  
  belongs_to :use
  belongs_to :license
    
  has_and_belongs_to_many :products
  
  def self.search(name, page, per_page = 12)
   conditions = sanitize_sql_for_conditions(["name like '%s'", "%#{name}%"])      
   paginate :order => 'name', :per_page => per_page, :page => page, :conditions => conditions
  end
  
end
