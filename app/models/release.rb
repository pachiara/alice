class Release < ActiveRecord::Base
  attr_accessible :product_id, :version_name, :sequential_number, :license_id, :check_result, :checked_at, :compatible_license_id, :groupage, :notes
   
  validates_uniqueness_of :version_name, scope: :product_id
  
  has_and_belongs_to_many :components
  belongs_to :product
  belongs_to :license, :foreign_key => "license_id"

  def self.search_release(product_name, groupage, page, per_page = 10)
    Release.joins(:product).order('products.name').where("name LIKE ? and groupage LIKE ?", "%#{product_name}%", "%#{groupage}%").paginate(page: page, per_page: per_page)
  end
   
end