class Component < ApplicationRecord
  include Loggable

  validates_presence_of :name, :title, :license_id
  validates :version, :uniqueness => {:scope => [:name]}
  validate  :purchase_or_own

#  belongs_to :use
  belongs_to :license

  has_and_belongs_to_many :releases

  def self.search(name, page, per_page = 10)
   order('name, version').where('name LIKE ?', "%#{name}%").paginate(page: page, per_page: per_page)
  end

  def purchase_or_own
    if purchased and own
      errors.add(:purchased, :incompatible)
      errors.add(:own, :incompatible)
    end
  end

  before_update do
    previous = Component.find(id)
    license = License.find(license_id).description
    license_previous = License.find(previous.license_id).description
    if (license_id != previous.license_id or purchased != previous.purchased or own != previous.own or leave_out != previous.leave_out) then
      if ALICE['txt_logging']
        alice_logger.info("
          Component: #{name}
          Version: #{version}
          License: #{license}
          License previous: #{license_previous}
          Own: #{own}
          Own previous: #{previous.own}
          Purchased: #{purchased}
          Purchased previous: #{previous.purchased}
          Leave_out: #{leave_out}
          Leave_out previous: #{previous.leave_out}
          Updated_by: #{user} ")
      end
      if ALICE['db_logging']
        le = LogEntry.new
        le.date = Time.now
        le.user = user
        le.object = "component"
        le.operation ="U"
        le.component = name
        le.version = version
        le.license = license
        le.license_previous = license_previous
        le.own = own
        le.own_previous = previous.own
        le.purchased =purchased
        le.purchased_previous = previous.purchased
        le.leave_out = leave_out
        le.leave_out_previous = previous.leave_out
        le.save      
      end
      SpyMailer.component_email(self, license).deliver_now unless ALICE['spy_mail_list'].blank?
    end
  end

  before_destroy do
    license = License.find(license_id).description
    if ALICE['txt_logging']
      alice_logger.info("
        Component: #{name}
        Version: #{version}
        License: #{license}
        Destroyed_by: #{user} ")
    end
    if ALICE['db_logging']
      le = LogEntry.new
      le.date = Time.now
      le.user = user
      le.object = "component"
      le.operation ="D"
      le.component = name
      le.version = version
      le.license = license
    end
    SpyMailer.component_destroyed_email(self, license).deliver_now unless ALICE['spy_mail_list'].blank?
  end


end
