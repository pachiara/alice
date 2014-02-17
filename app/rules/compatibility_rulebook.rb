# encoding: utf-8

require 'ruleby'
include Ruleby

class CompatibilityRulebook < Rulebook
  
  # Vedi http://www.dwheeler.com/essays/floss-license-slide.html
  Floss_slide = Hash.new
  rules = Rule.all
  rules.each do |rule|
    entries = Array.new
    rule.rule_entries.order("order_id").each do |entry|
       entries.push(entry.license)
    end
    Floss_slide[rule.license]=entries
  end

  # Cerca le licenze compatibili con la license1 all'interno delle licenze compatibili con la license2
  # e restituisce la PRIMA licenza compatibile trovata;
  # quindi L'ORDINE con cui sono passate license1 e license2 CAMBIA IL RISULTATO!
  def search_compatible(license1, license2)
    compatibles = Floss_slide[license1] & Floss_slide[license2]
    return compatibles ? compatibles[0] : nil 
  end
  
  def rules
    # Calcola la licenza richiesta 
    rule :Compatibility, {:priority => 4},
      [Product, :prod],
      [Component,:comp ] do |v|
        seeking_license = v[:comp].license.similar_license_id.nil? ? license = v[:comp].license : License.find(v[:comp].license.similar_license_id)
        if Floss_slide.include?(seeking_license)
          new_compatible_license = self.search_compatible(seeking_license, v[:prod].compatible_license)
          if new_compatible_license != nil and v[:prod].compatible_license != new_compatible_license
            v[:prod].addInfo("Componente #{v[:comp].name} con licenza #{v[:comp].license.name} #{v[:comp].license.version}", "cambia licenza compatibilità componenti in: #{new_compatible_license.name} #{new_compatible_license.version}")
            v[:prod].compatible_license = new_compatible_license
          end
        end
    end
  
  end
end