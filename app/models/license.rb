class License < ActiveRecord::Base
  attr_accessible :license_type_id, :category_id, :description, :name, :text_license, :version, :flag_osi, :id, :notes, :similar_license_id
  
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

    def alice_logger
    @@alice_logger ||= Logger.new("#{Rails.root}/log/alice.log")
  end

  def user=(u)
    @user = u
  end

  def user
    @user
  end
  
  before_update do
    previous = License.find(id)
    if (license_type_id != previous.license_type_id or similar_license_id != previous.similar_license_id or name != previous.name) then
      alice_logger.info("
        License: #{name}
        Version: #{version}
        Name previous: #{name}               
        Similar_License: #{License.find(similar_license_id).description}
        Similar_License previous: #{License.find(previous.similar_license_id).description}          
        License_type: #{LicenseType.find(license_type_id).description}
        License_type previous: #{LicenseType.find(previous.license_type_id).description}          
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
    alice_logger.info("
      License: #{name}
      Version: #{version}
      Similar_License: #{License.find(similar_license_id).description}
      License_type: #{LicenseType.find(license_type_id).description}
      Created_by: #{user} ")
  end
  
end
