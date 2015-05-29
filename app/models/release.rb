class Release < ActiveRecord::Base
  include Ruleby
  attr_accessible :product_id, :version_name, :sequential_number, :license_id,
                  :check_result, :checked_at, :compatible_license_id, :notes
  attr_accessor :warnings, :infos
   
  validates_presence_of :version_name, :sequential_number, :license_id
  validates_uniqueness_of :version_name, scope: :product_id
  
  has_and_belongs_to_many :components
  belongs_to :product
  belongs_to :license
  belongs_to :compatible_license, :class_name => "License", :foreign_key => "compatible_license_id"
  
  has_and_belongs_to_many :components
  has_many :detections, :dependent => :destroy


  def self.search_release(product_name, page, per_page = 10)
    Release.joins(:product).order('products.name').where("name LIKE ?", "%#{product_name}%").paginate(page: page, per_page: per_page)
  end

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

  def addWarning(key, text)
    @warnings || @warnings = ActiveModel::Errors.new(self)
    @warnings.add(key, text)
  end

  def addInfo(key, text)
    @infos || @infos = ActiveModel::Errors.new(self)
    @infos.add(key, text)
  end

  def precheck
    check_result = true
    if self.license.nil?
      self.errors.add("Impossibile eseguire il controllo:", "specificare una licenza per il prodotto.")
      check_result = false
    end
    if self.components.empty? 
      self.errors.add("Impossibile eseguire il controllo:", "il prodotto non ha componenti.")
      check_result = false
    else
      self.components.each do |component|
        if component.license.license_type.nil?
          self.errors.add("Impossibile eseguire il controllo:", 
           "specificare tipo licenza per licenza #{component.license.name} versione #{component.license.version}.")
          check_result = false
        end
      end
    end
    return check_result
  end

  def analyze_rules
    @release = self
    @components = @release.components.where(:own => false, :leave_out => false )
    # Inizializzazione
    @release.compatible_license = License.where("name=?", "public").first
    @release.check_result = true
    @release.addInfo("Licenza compatibilità componenti iniziale:",
                     " #{@release.compatible_license.name} #{@release.compatible_license.version}")

    engine :engine do |e|
      CompatibilityRulebook.new(e).rules
      e.assert @release
      @components.each do |component|
        e.assert component
      end
      e.match
    end

    engine :engine do |e|
      CheckRulebook.new(e).rules
      e.assert @release
      @components.each do |component|
        e.assert component
      end
      e.match
    end
  end


   
end