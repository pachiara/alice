class DetectedComponent < ApplicationRecord
  include Loggable

  belongs_to :detection

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
      queryString << "description LIKE '%#{word} %' or "
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
    # User in bianco in caso di aggiornamento automatico componenti identici su più rilevamenti:
    # il test serve a evitare scrittura di record di log e invio di mail inutili.  
      if !self.user.blank? 
        if ALICE['txt_logging']
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
        if ALICE['db_logging']
          le = LogEntry.new
          le.date = Time.now
          le.user = user
          le.object = "detected_component"
          le.operation ="U"
          le.product = detection.release.product.name
          le.product_release = detection.release.version_name
          le.detection = detection.name
          le.detected_component = name
          le.license = license
          le.license_previous = license_previous
          le.own = own
          le.own_previous = previous.own
          le.purchased =purchased
          le.purchased_previous = previous.purchased
          le.save
        end
        SpyMailer.detected_component_email(self, license).deliver_now unless ALICE['spy_mail_list'].blank?
      end
    end
  end

  before_destroy do
    # User impostato a livello detection => si sta cancellando tutta la detection
#    if !detection.user.nil?
#      self.user = detection.user
#    end
    # User non impostato => si sta cancellando tutta la release (niente log)
    if !self.user.nil? then
      license = license_id.nil? ? " " : License.find(license_id).description
      if ALICE['txt_logging']
        alice_logger.info("
          Product: #{detection.release.product.name}
          Release: #{detection.release.version_name}
          Detection: #{detection.name}
          DetectedComponent: #{name}
          License: #{license}
          Destroyed_by: #{user} ")
      end
      if ALICE['db_logging']
        le = LogEntry.new
        le.date = Time.now
        le.user = user
        le.object = "detected_component"
        le.operation ="D"
        le.product = detection.release.product.name
        le.product_release = detection.release.version_name
        le.detection = detection.name
        le.detected_component = name
        le.license = license
        le.save
      end
      SpyMailer.detected_component_destroyed_email(self, license).deliver_now unless ALICE['spy_mail_list'].blank?
    end
  end

end
