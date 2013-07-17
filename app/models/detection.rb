class Detection < ActiveRecord::Base
  attr_accessible :name, :product_id, :xml, :created_at, :xml_file_name, :xml_updated_at, :acquired
  
  has_attached_file :xml
  belongs_to :product
  has_many :detected_components, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :xml, :message => ''
  validates_uniqueness_of :name
  
  before_save :parse_file
  
  def parse_file
    tempfile = xml.queued_for_write[:original]
    doc = Nokogiri::XML(tempfile)
    parse_xml(doc)
  end
  
  def parse_xml(doc)
    doc.xpath('//licenses').each do |node|
      if node.xpath('license').length > 0
        node.xpath('license').each do |node|
          rc = DetectedComponent.new
          rc.name = node.xpath('../../artifactId').text
          rc.version = node.xpath('../../version').text
          if node.xpath('name').length > 0
            rc.license_name = parse_name(node.xpath('name').text)
            rc.license_version = parse_version(node.xpath('name').text, node.xpath('url').text)
            versions = rc.search_licenses(rc.license_name, rc.license_version)
            if versions.length == 1
              rc.license_id = versions[0].id
            end
          end
          component = Component.where("name = ? and version = ?", rc.name, rc.version).first
          if component != nil
            rc.component_id = component.id
            rc.license_id = component.license_id
          end
          self.detected_components << rc
        end
      else
        rc = DetectedComponent.new
        rc.name = node.xpath('../artifactId').text
        rc.version = node.xpath('../version').text
        rc.license_name = node.xpath('comment()').text
        component = Component.where("name = ? and version = ?", rc.name, rc.version).first
        if component != nil
          rc.component_id = component.id
          rc.license_id = component.license_id
        end
        self.detected_components << rc
      end
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
        c.checked_at = Date.today
        c.use_id = 1
        c.save
      end
      p.components.push(c) unless p.components.include?(c)
    end
    acquired = true
  end

end
