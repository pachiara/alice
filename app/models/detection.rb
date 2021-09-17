class Detection < ApplicationRecord
  include Loggable

  belongs_to :release
  has_many :detected_components, :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :xml, on: :create
  validates_uniqueness_of :name, scope: :release_id
  validate :xml_components_names, on: :create
  before_create :parse_file
  
  attr_accessor :xml
  
  def parse_file
    parse_xml(@doc)
    self.parsed_file_name = @xml.original_filename
    self.parsed_file_at   = DateTime.now
  end

  def parse_xml(doc)
    doc.xpath('//dependency').each do |node|
      node.xpath('licenses').each do |node|
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
              # cerca tag che segnala componente proprio (own)
              own_tag = node.xpath('../' + ALICE["own_component_tag_xpath"])
              if !own_tag.nil? and own_tag.text.include? ALICE["own_component_tag_value"]
                dc.own = true
              end
            end
            self.detected_components << dc
          end
        # componente rilevato senza tag <license>
        else
          dc = DetectedComponent.new
          dc.name = node.xpath('../artifactId').text
          dc.version = node.xpath('../version').text
          dc.license_name = node.xpath('comment()').text[0...255]
          # cerca tag che segnala componente proprio (own)
          own_tag = node.xpath(ALICE["own_component_tag_xpath"])
          if !own_tag.nil? and own_tag.text.include? ALICE["own_component_tag_value"]
            dc.own = true
          end
          identify_component(dc)
          self.detected_components << dc
        end
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
    # per componenti propri non controlla corrispondenza della release.
    if component == nil
      component = Component.where("name = ? and own = true", detected_component.name).first
    end
    if component != nil
      detected_component.component_id = component.id
      detected_component.license_id = component.license_id
      detected_component.own = component.own
      detected_component.purchased = component.purchased
    end
  end

  def parse_name(name)
    new_name = name.split(',')[0]
    if new_name.include?("ersion")
      new_name = new_name.split('ersion')[0].chop.rstrip
    end
    new_name = new_name.split(/\d+\.\d*\.*\d+/)[0].rstrip
    new_name = new_name.split('- v')[0].rstrip
    new_name = new_name.gsub(/['"]/,'')
    return new_name[0...255]
  end

  def parse_version(name, url)
    version = name.slice(/\d+\.\d*\.*\d+/)
    version = url.slice(/\d+\.\d*\.*\d+/) if (version.nil? && !url.nil?)
    return version
  end

  def validate_acquire
    if detected_components.empty?
      errors.add(I18n.t("activerecord.models.detection"),
                 I18n.t("errors.messages.check.no_detected_components", detection_name: "#{name}"))
    else
      detected_components.each do |component|
        if component.license_id.nil?
           errors.add("#{component.name}", "#{component.version}")
        end
      end
    end
  end

  def acquire
    r = Release.find(release_id)
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
          c.purchased = component.purchased
          c.save
        end
      end
      r.components.push(c) unless r.components.include?(c)
    end
    acquired = true
  end

  before_destroy do
    # User non impostato => si sta cancellando tutta la release (niente log)
    if !self.user.nil? then
      if ALICE['txt_logging']
        alice_logger.info("
          Product: #{release.product.name}
          Release: #{release.version_name}
          Detection: #{name}
          Destroyed_by: #{user} ")
      end
      if ALICE['db_logging']
        le = LogEntry.new
        le.date = Time.now
        le.user = user
        le.object = "detection"
        le.operation ="D"
        le.product = release.product.name
        le.product_release = release.version_name
        le.detection = name
        le.save
      end
      SpyMailer.detection_destroyed_email(self).deliver_now unless ALICE['spy_mail_list'].blank?
    end
  end
  
  def xml_components_names
    too_longs = Array.new
    name_max_length = Component.columns_hash['name'].sql_type[/\(.*?\)/].gsub(/[()]/, "").to_i
    version_max_length = Component.columns_hash['version'].sql_type[/\(.*?\)/].gsub(/[()]/, "").to_i
    @doc = Nokogiri::XML.parse(@xml)
    dependencies = @doc.xpath('//dependency') 
    dependencies.each do |dependency|
      name = dependency.xpath('artifactId').text
      version = dependency.xpath('version').text
      if name.length > name_max_length or version.length > version_max_length
        too_longs.push(I18n.t("errors.messages.detection.components_list_item", component_name: "#{name}", version: "#{version}"))
      end
    end
    if too_longs.length > 0
      errors.add(:xml, I18n.t("errors.messages.detection.too_long_components", components_list: " #{too_longs.to_s.gsub(/['"]/,'')}"))
    end
  end
 
end
