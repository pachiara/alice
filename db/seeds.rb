# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

LicenseType.delete_all
LicenseType.create!({:id => 1, :code => "P", :description => "Permissiva",                :protection_level => 0}, {:without_protection => true}) 
LicenseType.create!({:id => 2, :code => "L", :description => "Lesser (Copyleft leggera)", :protection_level => 1}, {:without_protection => true}) 
LicenseType.create!({:id => 3, :code => "S", :description => "Strong (Copyleft forte)",   :protection_level => 2}, {:without_protection => true}) 
LicenseType.create!({:id => 4, :code => "N", :description => "Network (Copyleft forte)",  :protection_level => 3}, {:without_protection => true}) 
LicenseType.create!({:id => 5, :code => "C", :description => "Copyright",                 :protection_level =>-1}, {:without_protection => true}) 


# Vedi http://www.dwheeler.com/essays/floss-license-slide.html
Floss_slide = {
  "public" => ["public", "mit", "bsd", "apache", "lgplv21", "lgplv21+", "lgplv3", "lgplv3+", "gplv2", "gplv2+", "gplv3", "gplv3+", "afferogplv3", "mpl11"],
  "mit" => ["mit", "bsd", "apache", "lgplv21", "lgplv21+", "lgplv3", "lgplv3+", "gplv2", "gplv2+", "gplv3", "gplv3+", "afferogplv3", "mpl11"],
  "bsd" => ["bsd", "apache", "lgplv21", "lgplv21+", "lgplv3", "lgplv3+", "gplv2", "gplv2+", "gplv3", "gplv3+", "afferogplv3", "mpl11"],
  "apache" => ["apache", "lgplv3", "lgplv3+", "gplv3", "gplv3+", "afferogplv3"],
  "lgplv21" => ["lgplv21", "gplv2", "gplv2+", "gplv3", "gplv3+", "afferogplv3"],
  "lgplv21+" => ["lgplv21+", "lgplv21", "lgplv3", "lgplv3+", "gplv2", "gplv2+", "gplv3", "gplv3+", "afferogplv3"],
  "lgplv3" => ["lgplv3", "lgplv3+", "gplv3", "gplv3+", "afferogplv3"],
  "lgplv3+" => ["lgplv3+", "gplv3", "gplv3+", "afferogplv3"],
  "mpl11" => ["mpl11"],
  "gplv2" => ["gplv2"],
  "gplv2+" => ["gplv2+", "gplv2", "gplv3", "gplv3+", "afferogplv3"],
  "gplv3" => ["gplv3", "gplv3+", "afferogplv3"],
  "gplv3+" => ["gplv3+", "afferogplv3"],
  "afferogplv3" => ["afferogplv3"]
}

Rule.delete_all
RuleEntry.delete_all

Floss_slide.each do |key, value|
  rule_lic = License.where("name=?", key).first
  rule = Rule.create(:name => rule_lic.name, :license_id => rule_lic.id)
  value.each_index do |i|
    entry_lic = License.where("name=?", value[i]).first
    rule.rule_entries.create(:license_id => entry_lic.id, :order => i+1)
  end
end
