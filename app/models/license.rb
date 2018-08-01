class License < ApplicationRecord
  include Loggable

  validates_presence_of :name, :description, :category, :license_type
  validates_uniqueness_of :name

  belongs_to :category
  belongs_to :license_type

  has_many   :releases
  has_many   :components

  def self.search(name, page, per_page = 10)
    order('name, version').where('name LIKE ?', "%#{name}%").paginate(page: page, per_page: per_page)
  end

  def self.search_order(order, page, per_page = 10)
    order(order).paginate(page: page, per_page: per_page)
  end

  before_update do
    previous = License.find(id)
    if similar_license_id.nil? then
      similar_license = " "
    else
      similar_license = License.find(similar_license_id).description
    end
    if previous.similar_license_id.nil? then
      similar_license_previous = " "
    else
      similar_license_previous = License.find(previous.similar_license_id).description
    end
    if license_type_id.nil? then
      license_type = " "
    else
      license_type = LicenseType.find(license_type_id).description
    end
    if previous.license_type_id.nil? then
      license_type_previous = " "
    else
      license_type_previous = LicenseType.find(previous.license_type_id).description
    end
    if (license_type_id != previous.license_type_id or similar_license_id != previous.similar_license_id or name != previous.name) then
      if ALICE['txt_logging']
        alice_logger.info("
          License: #{name}
          Version: #{version}
          Name previous: #{name}
          Similar_License: #{similar_license}
          Similar_License previous: #{similar_license_previous}
          License_type: #{license_type}
          License_type previous: #{license_type_previous}
          Updated_by: #{user} ")
      end
      if ALICE['db_logging']
        le = LogEntry.new
        le.date = Time.now
        le.user = user
        le.object = "license"
        le.operation = "U"
        le.license = name
        le.version = version
        le.license_previous = previous.name
        le.similar_license = similar_license
        le.similar_License_previous = similar_license_previous
        le.license_type =license_type
        le.license_type_previous = license_type_previous
        le.save
      end
      SpyMailer.license_email(self, similar_license, license_type).deliver_now unless ALICE['spy_mail_list'].blank?
    end
  end

  before_destroy do
    if ALICE['txt_logging']
      alice_logger.info("
        License: #{name}
        Version: #{version}
        Destroyed_by: #{user} ")
    end
    if ALICE['db_logging']
      le = LogEntry.new
      le.date = Time.now
      le.user = user
      le.object = "license"
      le.operation = "D"
      le.license = name
      le.version = version
      le.save
    end
    SpyMailer.license_destroyed_email(self).deliver_now unless ALICE['spy_mail_list'].blank?
  end

  before_create do
    if similar_license_id.nil? then
      similar_license = " "
    else
      similar_license = License.find(similar_license_id).description
    end
    if license_type_id.nil? then
      license_type = " "
    else
      license_type = LicenseType.find(license_type_id).description
    end
    if ALICE['txt_logging']
      alice_logger.info("
        License: #{name}
        Version: #{version}
        Similar_License: #{similar_license}
        License_type: #{license_type}
        Created_by: #{user} ")
    end
    if ALICE['db_logging']
      le = LogEntry.new
      le.date = Time.now
      le.user = user
      le.object = "license"
      le.operation = "C"
      le.license = name
      le.version = version
      le.similar_license = similar_license
      le.license_type = license_type
      le.save
    end
    SpyMailer.license_created_email(self, similar_license, license_type).deliver_now unless ALICE['spy_mail_list'].blank?
  end

end
