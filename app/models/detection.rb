class Detection < ActiveRecord::Base
  attr_accessible :name, :product_id, :xml, :created_at, :xml_file_name, :xml_updated_at, :acquired
  
  has_attached_file :xml
  belongs_to :product
  has_many :detected_components, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :xml, :message => ''
  validates :name, :uniqueness => {:scope => [:product_id]}
  validates_attachment_content_type :xml, :content_type => "text/xml"
  before_save :parse_file
  
  def parse_file
    tempfile = xml.queued_for_write[:original]
    doc = Nokogiri::XML(tempfile)
    parse_xml(doc)
  end
  
  def parse_xml(doc)
    doc.xpath('//licenses').each do |node|
      if node.xpath('license').length > 0
        # un componente può avere più tag <license> 
        node.xpath('license').each do |node|
          dc = DetectedComponent.new
          dc.name = node.xpath('../../artifactId').text
          dc.version = node.xpath('../../version').text
          if node.xpath('name').length > 0
            dc.license_name = parse_name(node.xpath('name').text)
            dc.license_version = parse_version(node.xpath('name').text, node.xpath('url').text)
          end
          identify_component(dc)
          if dc.component_id.nil?
            # cerca licenza corrispondente 
            versions = dc.search_licenses(dc.license_name, dc.license_version)
            dc.license_id = versions[0].id if versions.length == 1
          end
          self.detected_components << dc
        end
      # componente rilevato senza tag <license>
      else
        dc = DetectedComponent.new
        dc.name = node.xpath('../artifactId').text
        dc.version = node.xpath('../version').text
        dc.license_name = node.xpath('comment()').text
        identify_component(dc)
        self.detected_components << dc
      end
    end
  end
  
  # Se il componente è registrato assegna id e licenza corrispondente 
  def identify_component(detected_component)
    component = Component.where("name = ? and version = ?", detected_component.name, detected_component.version).first
    if component == nil
      major_release = detected_component.version.split('.')[0]
      component = Component.where("name = ? and version like ?", detected_component.name, "#{major_release}.%").first
    end
    if component != nil
      detected_component.component_id = component.id
      detected_component.license_id = component.license_id
      detected_component.own = component.own
    end
  end

  def parse_name(name)
    new_name = name.split(',')[0]
    if new_name.include?("ersion")
      new_name = new_name.split('ersion')[0].chop.rstrip
    end
    new_name = new_name.split(/\d+\.\d*\.*\d+/)[0].rstrip
    new_name = new_name.split('- v')[0].rstrip
    return new_name
  end
  
  def parse_version(name, url)
    version = name.slice(/\d+\.\d*\.*\d+/)
    version = url.slice(/\d+\.\d*\.*\d+/) if (version.nil? && !url.nil?)
    return version
  end

  def validate_acquire
    if detected_components.empty?
      errors.add("Rilevamento: #{name}", "Nessun componente rilevato")
    else
      detected_components.each do |component|
        if component.license_id.nil?
           errors.add("#{component.name}", "#{component.version}")
        end
      end
    end
  end
  
  def acquire
    p = Product.find(product_id)
    detected_components.each do |component|
      if !component.component_id.nil?
        c = Component.find(component.component_id)
      # detected_component.component_id è impostato durante il parsing del file .xml
      # Il metodo acquire è eseguito a distanza di tempo, durante il quale un componente con stesso nome e versione
      # potrebbe essere stato creato manualmente o da un'altra acquisizione. 
      else
        c = Component.where("name = ? AND version = ?", component.name, component.version).first
        if c.nil?
          c = Component.new
          c.name = component.name
          c.version = component.version
          c.title = component.name
          c.description = component.name
          c.license_id = component.license_id
          c.own = component.own
          c.checked_at = Date.today
          c.use_id = 1
          c.save
        end
      end
      p.components.push(c) unless p.components.include?(c)
    end
    acquired = true
  end

end
