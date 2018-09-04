class Release < ApplicationRecord
  include Ruleby
  include Loggable

  attr_accessor :warnings, :infos

  validates_presence_of :version_name, :sequential_number, :license_id
  validates_uniqueness_of :version_name, scope: :product_id
  validates_uniqueness_of :sequential_number, scope: :product_id

  has_and_belongs_to_many :components
  belongs_to :product
  belongs_to :license
  belongs_to :compatible_license, :optional => true, :class_name => "License", :foreign_key => "compatible_license_id"

  has_many :detections, :dependent => :destroy

  after_save do
    product.update_last_release
    product.save
  end

  after_destroy do
    product = Product.find(product_id)
    product.update_last_release
    product.save
  end

  def self.search_release(product_name, page, per_page = 10)
    Release.joins(:product).order('products.name').where("name LIKE ?", "%#{product_name}%").paginate(page: page, per_page: per_page)
  end

  def add_relation(component_add = [])
    component_add.each do |component_id|
      component = Component.find(component_id)
      unless self.components.include?(component)
        components<< component
      end
    end
  end

  def del_relation(component_del = [])
   component_del.each do |component_id|
      component = Component.find(component_id)
      component_license = License.find(component.license_id)
      if self.components.include?(component)
        if ALICE['txt_logging']
          alice_logger.info("
            Product: #{product.name}
            Release: #{version_name}
            Component: #{component.name}
            Component_license: #{component_license.description}
            Destroyed_by: #{user} ")
        end
        if ALICE['db_logging']
          le = LogEntry.new
          le.date = Time.now
          le.user =user
          le.object = "relation"
          le.operation = "D"
          le.product = product.name
          le.product_release = version_name
          le.component = component.name
          le.license = component_license.description
          le.save
        end
        SpyMailer.relation_destroyed_email(product.name, version_name, component, component_license, user).deliver_now unless ALICE['spy_mail_list'].blank?

        components.delete(component)
      end
    end
  end

  def next_sequential_number
    if self.product.nil? || self.product.releases.empty?
      return 1
    else
      return (self.product.releases.order(:sequential_number).last.sequential_number.to_int + 1)
    end
  end

  def addWarning(key, text)
    @warnings || @warnings = ActiveModel::Errors.new(self)
    @warnings.add(key, text)
  end

  def addInfo(key, text)
    @infos || @infos = ActiveModel::Errors.new(self)
    @infos.add(key, text)
  end

  def precheck
    check_result = true
    if !self.product.use.name
      self.errors.add(I18n.t("errors.messages.check.not_executable"),
         I18n.t("errors.messages.check.no_use"))
      check_result = false
    end
    if self.license.nil?
      self.errors.add(I18n.t("errors.messages.check.not_executable"),
         I18n.t("errors.messages.check.no_license"))
      check_result = false
    end
    self.detections.each do |detection|
      if !detection.acquired
        self.errors.add(I18n.t("errors.messages.check.not_executable"),
           I18n.t("errors.messages.check.detection_not_acquired"))
        return check_result = false
      end
    end
    if self.components.empty?
      self.errors.add(I18n.t("errors.messages.check.not_executable"),
         I18n.t("errors.messages.check.no_components"))
      check_result = false
    else
      self.components.each do |component|
        if component.license.license_type.nil?
          self.errors.add(I18n.t("errors.messages.check.not_executable"),
            I18n.t("errors.messages.check.no_license_type", license_name: "#{component.license.name}",
                   license_version: "#{component.license.version}"))
          check_result = false
        end
      end
    end
    return check_result
  end

  def analyze_rules
    @release = self
    @components = @release.components.where(:own => false, :leave_out => false )
    # Inizializzazione
    @release.compatible_license = License.where("name=?", "public").first
    @release.check_result = true
    @release.addInfo(I18n.t("activerecord.models.license"),
                     I18n.t("infos.check.start_license", license_name: "#{@release.compatible_license.name}",
                     license_version: "#{@release.compatible_license.version}"))

    engine :engine do |e|
      CompatibilityRulebook.new(e).rules
      e.assert @release
      @components.each do |component|
        e.assert component
      end
      e.match
    end

    engine :engine do |e|
      CheckRulebook.new(e).rules
      e.assert @release
      @components.each do |component|
        e.assert component
      end
      e.match
    end
  end

end
