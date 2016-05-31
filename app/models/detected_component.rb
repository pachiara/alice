class DetectedComponent < ActiveRecord::Base
  include Loggable
  
  belongs_to :detection
  attr_accessible :component_id, :license_id, :license_name, :license_version, :name, :version, :own, :purchased
  
  validates_presence_of :name, :version

  @@grubber = ["license","public","software","none","and","the",'^no ', " no ","information","available", '\.']
  
 
  def purify_name(name)
    purified_name = String.new(str=name)
    @@grubber.each do |dirty|
      purified_name.gsub!(/#{dirty}/i,'')
    end
    return purified_name.strip
  end
  
  def search_licenses(name, version)
    return License.all if name.nil?
    words = purify_name(name).split
    return License.all if words.length == 0

    queryString = "("
    words.each do |word|
      queryString << "description LIKE '%#{word}%' or "
    end 
    queryString = queryString[0..-5] + ')'
    if version != nil
      queryString << " and version LIKE '%#{version}%'"
    end
    if License.where(queryString).count > 0
      return License.where(queryString).order("description")
    else
      return License.order("description")
    end
  end

  after_update do
    # Se il componente è presente in più rilevamenti della release, aggiorna i dati su tutti
    same_release_detections = self.detection.release.detections
    same_release_detections.each do |same_release_detection|
      same_components = same_release_detection.detected_components.where(name: self.name, license_id: nil)
      same_components.each do |same_component|
        same_component.license_id = self.license_id
        same_component.purchased = self.purchased
        same_component.own= self.own
        same_component.save
      end
    end
  end

  before_update do
    previous = DetectedComponent.find(id)
    license = license_id.nil? ? " " :  License.find(license_id).description
    license_previous = previous.license_id.nil? ? " " :  License.find(previous.license_id).description
    if (license_id != previous.license_id or purchased != previous.purchased or own != previous.own) then
      alice_logger.info("
        Product: #{detection.release.product.name}
        Release: #{detection.release.version_name}
        Detection: #{detection.name}
        DetectedComponent: #{name}
        License: #{license}
        License previous: #{license_previous}          
        Own: #{own}
        Own previous: #{previous.own}
        Purchased: #{purchased}
        Purchased previous: #{previous.purchased}
        Updated_by: #{user} ")
    end
  end
  
  before_destroy do
    # User impostato a livello detection => si sta cancellando tutta la detection
    if !detection.user.nil? 
      self.user = detection.user
    end
    # User non impostato => si sta cancellando tutta la release (niente log)
    if !self.user.nil? then
      license = license_id.nil? ? " " : License.find(license_id).description
      alice_logger.info("
        Product: #{detection.release.product.name}
        Release: #{detection.release.version_name}
        Detection: #{detection.name}
        DetectedComponent: #{name}
        License: #{license}
        Destroyed_by: #{user} ")
    end
  end
 
end
