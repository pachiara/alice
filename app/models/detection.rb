class Detection < ActiveRecord::Base
  attr_accessible :name, :product_id, :xml, :created_at, :xml_file_name, :xml_updated_at, :acquired
  
  has_attached_file :xml
  belongs_to :product
  has_many :detected_components, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :xml, :message => ''
  validates :name, :uniqueness => {:scope => [:product_id]}
  
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
    major_release = detected_component.version.split('.')[0]
    component = Component.where("name = ? and version like ?", detected_component.name, "#{major_release}.%").first
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
    detected_components.each do |component|
      if component.license_id.nil?
         errors.add("#{component.name}", "#{component.version}")
      end
    end
  end
  
  def acquire
    p = Product.find(product_id)
    detected_components.each do |component|
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
      p.components.push(c) unless p.components.include?(c)
    end
    acquired = true
  end

end
