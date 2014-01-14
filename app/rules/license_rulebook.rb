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
  distribution_impossible = false;

  # Cerca le licenze compatibili con la license1 all'interno delle licenze compatibili con la license2
  # e restituisce la PRIMA licenza compatibile trovata;
  # quindi L'ORDINE con cui sono passate license1 e license2 CAMBIA IL RISULTATO!
  def search_compatible(license1, license2)
    compatibles = Floss_slide[license1] & Floss_slide[license2]
    return compatibles ? compatibles[0] : nil 
  end
  
  def rules
    # Inizializzazione
    rule :New, {:priority => 10}, 
      [Product, :prod] do |v|
        v[:prod].compatible_license = License.where("name=?", "public").first
        v[:prod].result = true
        v[:prod].addInfo("Licenza compatibilità componenti iniziale:", " #{v[:prod].compatible_license.name} #{v[:prod].compatible_license.version}")
    end
    

    # Calcola la licenza richiesta 
    rule :Compatibility, {:priority => 4},
      [Product, :prod],
      [Component,:comp ] do |v|
        seeking_license = v[:comp].license.similar_license_id.nil? ? license = v[:comp].license : License.find(v[:comp].license.similar_license_id)
        if !Floss_slide.include?(seeking_license)
            v[:prod].result = nil
            error_string = "impossibile verificare compatibilità. " +
                           "Mancano regole per la licenza #{v[:comp].license.name}."
            v[:prod].errors.add("Componente #{v[:comp].name}:", "#{error_string}")
            next
        end
        new_compatible_license = self.search_compatible(seeking_license, v[:prod].compatible_license)
        if new_compatible_license == nil 
          distribution_impossible = true;
          error_string = "licenza #{v[:comp].license.name} " +
                         "incompatibile con licenza: #{v[:prod].compatible_license.name}"
          v[:prod].errors.add("Componente #{v[:comp].name}:", "#{error_string}")
        elsif v[:prod].compatible_license != new_compatible_license
          v[:prod].addInfo("Componente #{v[:comp].name} con licenza #{v[:comp].license.name} #{v[:comp].license.version}", "cambia licenza compatibilità componenti in: #{new_compatible_license.name} #{new_compatible_license.version}")
          v[:prod].compatible_license = new_compatible_license
        end
    end
 
    # Distribuzione di prodotto proprietario con licenza componenti strong
    rule :Distribution, {:priority => 2},
      [Product, :prod] do |v|
        if v[:prod].use.name == "DIS" and v[:prod].compatible_license.license_type.protection_level > 1 and v[:prod].license.license_type.protection_level < 0
          v[:prod].result = false
          v[:prod].errors.add("Licenza e uso del prodotto", "contrastano con la licenza compatibilità componenti.")
        end
      end
    
    # Servizio esterno di prodotto proprietario con licenza componenti network protective
    rule :ExternalService, {:priority => 2},
      [Product, :prod] do |v|
        if v[:prod].use.name == "SUE" and v[:prod].compatible_license.license_type.protection_level > 2 and v[:prod].license.license_type.protection_level < 0
          v[:prod].result = false
          v[:prod].errors.add("Licenza e uso del prodotto", "contrastano con la licenza compatibilità componenti.")
        end
      end
  
  end
end