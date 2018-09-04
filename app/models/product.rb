class Product < ApplicationRecord

  validates_presence_of :name, :title
  validates_uniqueness_of :name

  before_validation :strip_whitespace, :only => [:name]
  
  belongs_to :use
  has_many :releases, :dependent => :destroy
  def last_release
    return self.releases.order("sequential_number").last
  end

  def self.search_order(name, groupage, sort_column, sort_order, page, per_page = 10)
    if sort_column.nil? then sort_column = 'name' end
    if sort_order.nil? then sort_order = ' ASC' end

    sort = case sort_column.nil? ? 'name' : sort_column
      when 'name', 'updated_at' then
        sort_column + sort_order
      when 'groupage' then
        sort_column + sort_order + ', name'
      when 'check_result' then
        'last_release_' + sort_column + sort_order + ', name'
      else #checked_at
        'last_release_' + sort_column + sort_order + ', name'
    end
    order(sort).where('name LIKE ? and groupage LIKE ? ', "%#{name}%", "%#{groupage}%").paginate(page: page, per_page: per_page)
  end

  def update_last_release
    if !last_release.nil?
      self.last_release_version_name = last_release.version_name
      self.last_release_checked_at = last_release.checked_at
      self.last_release_check_result = last_release.check_result
    else
      self.last_release_version_name = nil
      self.last_release_checked_at = nil
      self.last_release_check_result = nil
    end
  end
  
  def strip_whitespace
    self.name = self.name.strip unless self.name.nil?
  end

end
