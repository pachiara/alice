# encoding: utf-8

require 'ruleby'
include Ruleby

class LicenseRulebook < Rulebook
  
  # Vedi http://www.dwheeler.com/essays/floss-license-slide.html
  Floss_slide = Hash.new
  rules = Rule.all
  rules.each do |rule|
    entries = Array.new
    rule.rule_entries.each do |entry|
       entries.push(entry.license)
    end
    Floss_slide[rule.license]=entries
  end

  def search_compatible(license1, license2)
    compatibles = Floss_slide[license1] & Floss_slide[license2]
    return compatibles ? compatibles[0] : nil 
  end
  
  def rules
    # Inizializzazione
    rule :New, {:priority => 10}, 
      [Product, :prod] do |v|
#        v[:prod].compatible_license = v[:prod].license
        v[:prod].compatible_license = License.where("name=?", "public").first
        v[:prod].result = true
    end
    
=begin    
    # Prodotto proprietario e componente con licenza strong
    rule :Strong, {:priority => 5},
      [Product, :prod],
      [Component,:comp ] do |v|
        puts v[:comp].name
        if v[:prod].compatible_license.license_type.protection_level > 1 and v[:prod].license.license_type.protection_level < 0 
          v[:prod].result = false
#          print "****** Licenza Prodotto incompatibile con "
#          puts "licenza #{v[:comp].license.name}  #{v[:comp].license.version}"
#          puts "Componente: #{v[:comp].name}  #{v[:comp].version}"
          error_string = "Licenza Prodotto incompatibile con "
          error_string << "licenza #{v[:comp].license.name}  #{v[:comp].license.version}"
          error_string << "Componente: #{v[:comp].name}  #{v[:comp].version}"
          v[:prod].errors.add("#{v[:comp].name}", "#{error_string}")
        end    
    end
=end
    # Calcola la licenza richiesta 
    rule :Compatibility, {:priority => 4},
      [Product, :prod],
      [Component,:comp ] do |v|
        new_compatible_license = self.search_compatible(v[:prod].compatible_license, v[:comp].license)
        if new_compatible_license == nil 
          v[:prod].result = false
          error_string = "#{v[:comp].name} licenza #{v[:comp].license.name} " +
                         "incompatibile con licenza: #{v[:prod].compatible_license.name}"
          v[:prod].errors.add("Componente: ", "#{error_string}")
        elsif v[:prod].compatible_license != new_compatible_license
          v[:prod].compatible_license = new_compatible_license
        end
    end
  
    # Prodotto proprietario e licenza richiesta strong
    rule :Strong, {:priority => 2},
      [Product, :prod] do |v|
        if v[:prod].compatible_license.license_type.protection_level > 1 and v[:prod].license.license_type.protection_level < 0 
          v[:prod].result = false
          v[:prod].errors.add(:license_id, "incompatibile con licenza compatibilità componenti.")
        end    
    end
    
=begin
    rule :Sentenza, {:priority => 1}, 
      [Product, :prod] do |v|
        if v[:prod].result == false
#          v[:prod].compatible_license = nil
        end
    end
=end
    
  end
end