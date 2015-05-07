class Product < ActiveRecord::Base
  include Ruleby
  
  attr_accessible :description, :name, :notes, :title, :use_id
   
  attr_accessor :warnings, :infos
  
  validates_presence_of :name, :title, :use_id
  validates_uniqueness_of :name
  
  belongs_to :use
  belongs_to :license
  belongs_to :compatible_license, :class_name => "License", :foreign_key => "compatible_license_id"
  
  has_and_belongs_to_many :components
  has_many :detections, :dependent => :destroy
  has_many :releases, :dependent => :destroy
  
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
#   order('name').where('name LIKE ? and groupage LIKE ?', "%#{name}%","%#{groupage}%").paginate(page: page, per_page: per_page)
   order('name').where('name LIKE ?', "%#{name}%").paginate(page: page, per_page: per_page)
  end
  
  def self.search_order(order, page, per_page = 10)
    order(order).paginate(page: page, per_page: per_page)
  end
  
  def addWarning(key, text)
    @warnings || @warnings = ActiveModel::Errors.new(self)
    @warnings.add(key, text)
  end

  def addInfo(key, text)
    @infos || @infos = ActiveModel::Errors.new(self)
    @infos.add(key, text)
  end

  def precheck
    result = true
    if self.license.nil?
      self.errors.add("Impossibile eseguire il controllo:", "specificare una licenza per il prodotto.")
      result = false
    end
    if self.components.empty? 
      self.errors.add("Impossibile eseguire il controllo:", "il prodotto non ha componenti.")
      result = false
    else
      self.components.each do |component|
        if component.license.license_type.nil?
          self.errors.add("Impossibile eseguire il controllo:", 
           "specificare tipo licenza per licenza #{component.license.name} versione #{component.license.version}.")
          result = false
        end
      end
    end
    return result
  end

  def analyze_rules
    @product = self
    @components = @product.components.where(:own => false, :leave_out => false )
    # Inizializzazione
    @product.compatible_license = License.where("name=?", "public").first
    @product.result = true
    @product.addInfo("Licenza compatibilità componenti iniziale:",
                     " #{@product.compatible_license.name} #{@product.compatible_license.version}")

    engine :engine do |e|
      CompatibilityRulebook.new(e).rules
      e.assert @product
      @components.each do |component|
        e.assert component
      end
      e.match
    end

    engine :engine do |e|
      CheckRulebook.new(e).rules
      e.assert @product
      @components.each do |component|
        e.assert component
      end
      e.match
    end
  end
  
end
