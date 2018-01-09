class License < ApplicationRecord
  include Loggable

  validates_presence_of :name, :description
  validates_uniqueness_of :name

  belongs_to :category
  belongs_to :license_type

  has_many   :products

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
      lcense_type = " "
    else
      license_type = LicenseType.find(license_type_id).description
    end
    if previous.license_type_id.nil? then
      license_type_previous = " "
    else
      license_type_previous = LicenseType.find(previous.license_type_id).description
    end
    if (license_type_id != previous.license_type_id or similar_license_id != previous.similar_license_id or name != previous.name) then
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
  end

  before_destroy do
    alice_logger.info("
      License: #{name}
      Version: #{version}
      Destroyed_by: #{user} ")
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
    alice_logger.info("
      License: #{name}
      Version: #{version}
      Similar_License: #{similar_license}
      License_type: #{license_type}
      Created_by: #{user} ")
  end

end
