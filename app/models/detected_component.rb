class DetectedComponent < ActiveRecord::Base
  belongs_to :detection
  attr_accessible :component_id, :license_id, :license_name, :license_version, :name, :version
  
  validates_presence_of :name, :version

  @@grubber = ["license", "public", "software" ,"and", "the", "no", "information", "available"]
  
  def purify_name(name)
    purified_name = String.new(str=name)
    @@grubber.each do |dirty|
      purified_name.gsub!(/#{dirty}/i,'')
    end
    return purified_name.strip
  end
  
  def search_license(name, version)
    return License.all if name.nil?
    words = purify_name(name).split
    return License.all if words.length == 0

    queryString = "("
    words.each do |word|
      queryString << "description LIKE '%#{word}%' or "
    end 
    queryString = queryString[0..-5] + ')'
    if !version.nil?
      queryString << " and version LIKE '%#{version}%'"
    end
#puts queryString
    return License.where(queryString).order("description")
  end

  def search_component(name, version)
    words = name.split

    queryString = "("
    words.each do |word|
      queryString << "description LIKE '%#{word}%' or "
    end 
    queryString = queryString[0..-5] + ')'
    if !version.nil?
      queryString << " and version LIKE '%#{version}%'"
    end
#puts queryString
    return Component.where(queryString).order("description")
  end
  
end
