# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

LicenseType.delete_all
LicenseType.create!(:id => 1, :code => "P", :description => "Permissiva", :protection_level => 0 ) 
LicenseType.create!(:id => 2, :code => "L", :description => "Lesser (Copyleft leggera)", :protection_level => 1 ) 
LicenseType.create!(:id => 3, :code => "S", :description => "Strong (Copyleft forte)", :protection_level => 2 ) 
LicenseType.create!(:id => 4, :code => "N", :description => "Network (Copyleft forte)", :protection_level => 3 ) 
LicenseType.create!(:id => 5, :code => "C", :description => "Copyright", :protection_level => -1 ) 
