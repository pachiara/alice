class Product < ActiveRecord::Base
  attr_accessible :checked_at, :description, :license_id, :name, :notes, :result, :title, :use_id, :version,
   :compatible_license_id, :groupage
   
  attr_accessor :warnings, :infos
  
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
   
  def delete_components
    self.components.clear
  end 
   
  def self.search(name, groupage, page, per_page = 10)
   conditions = sanitize_sql_for_conditions(["name like '%s'", "%#{name}%"])      
   conditions << sanitize_sql_for_conditions([" and groupage like '%s'", "%#{groupage}%"]) unless groupage.nil? or groupage.empty?
   paginate :order => 'name, version', :per_page => per_page, :page => page, :conditions => conditions
  end
  
  def self.search_order(order, page, per_page = 10)
    paginate :order => order, :per_page => per_page, :page => page
  end
  
  def check
    engine = Ruleby::Core::Engine.new
    engine do |e|
      LicenseRulebook.new(e).rules
    end
  end
  
  def addWarning(key, text)
    @warnings || @warnings = ActiveModel::Errors.new(self)
    @warnings.add(key, text)
  end

  def addInfo(key, text)
    @infos || @infos = ActiveModel::Errors.new(self)
    @infos.add(key, text)
  end

  
end
