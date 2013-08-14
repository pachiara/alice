class Product < ActiveRecord::Base
  attr_accessible :checked_at, :description, :license_id, :name, :notes, :result, :title, :use_id, :version,
   :compatible_license_id
  
  validates_presence_of :name, :title, :use_id
  validates_uniqueness_of :name
  
  belongs_to :use
  belongs_to :license
  belongs_to :compatible_license, :class_name => "License", :foreign_key => "compatible_license_id"
  
  has_and_belongs_to_many :components
  has_many :detections, :dependent => :destroy
  
  def add_relation(component_add = [])
    component_add.each do |component_id|
      component = Component.find(component_id)
      unless self.components.include?(component)
        components<<component
      end
    end
  end

  def del_relation(component_del = [])
   component_del.each do |component_id|
      component = Component.find(component_id)
      if self.components.include?(component)
        components.delete(component)
      end  
    end    
  end
   
  def self.search(name, page, per_page = 10)
   conditions = sanitize_sql_for_conditions(["name like '%s'", "%#{name}%"])      
   paginate :order => 'name, version', :per_page => per_page, :page => page, :conditions => conditions
  end
  
  def check
    engine = Ruleby::Core::Engine.new
    engine do |e|
      LicenseRulebook.new(e).rules
    end
  end
  
end
