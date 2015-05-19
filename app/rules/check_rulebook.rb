# encoding: utf-8

require 'ruleby'
include Ruleby

class CheckRulebook < Rulebook
  
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
    # Componente con licenza proprietaria non acquistata
    rule :toBuyComponent, {:priority => 5},
      [Release, :rel],
      [Component,:comp ] do |v|
        if v[:comp].license.license_type.protection_level == -1
          @not_free_components = true
          if !v[:comp].purchased
            v[:rel].check_result = false
            error_string = "con licenza proprietaria #{v[:comp].license.name} non acquistato"
            v[:rel].errors.add("Componente #{v[:comp].name}:", "#{error_string}")
          end
        end
      end
    
    # Segnalazione componenti incompatibili
    rule :Compatibility, {:priority => 4},
      [Release, :rel],
      [Component,:comp ] do |v|
        seeking_license = v[:comp].license.similar_license_id.nil? ? license = v[:comp].license : License.find(v[:comp].license.similar_license_id)
        if !Floss_slide.include?(seeking_license)
            v[:rel].check_result = nil
            error_string = "impossibile verificare compatibilità. " +
                           "Mancano regole per la licenza #{v[:comp].license.name}."
            v[:rel].errors.add("Componente #{v[:comp].name}:", "#{error_string}")
            next
        end
        new_compatible_license = self.search_compatible(seeking_license, v[:rel].compatible_license)
        if new_compatible_license == nil
          error_string = "licenza #{v[:comp].license.name} " +
                         "incompatibile con licenza: #{v[:rel].compatible_license.name}"
          if (v[:rel].product.use.name == "DIS") # or v[:rel].use.name == "SUE")  
            v[:rel].check_result = false
            v[:rel].errors.add("Componente #{v[:comp].name}:", "#{error_string}")
          else
            v[:rel].addWarning("Componente #{v[:comp].name}:", "#{error_string}")
          end
        end
      end

=begin
    # Componente non libero e licenza prodotto copyleft strong
    rule :Virality, {:priority => 1},
      [Release, :rel],
      [Component,:comp ] do |v|
        if v[:comp].license.license_type.protection_level < 0 and
           v[:rel].compatible_license.license_type.protection_level > 1 and
           v[:rel].use.name == "DIS"
              v[:rel].result = false
              v[:rel].errors.add("Componente non libero: #{v[:comp].name} licenza: #{v[:comp].license.name}", 
              "incompatibile con licenza compatibilità componenti di tipo copyleft strong")
        end
    end
=end
 
    # Distribuzione di prodotto proprietario con licenza componenti strong
    rule :Distribution, {:priority => 2},
      [Release, :rel] do |v|
        if v[:rel].product.use.name == "DIS" and 
           v[:rel].compatible_license.license_type.protection_level > 1 and
           v[:rel].license.license_type.protection_level < 0
              v[:rel].check_result = false
              v[:rel].errors.add("Licenza e uso del prodotto", "contrastano con la licenza compatibilità componenti.")
        end
      end
    
    # Servizio esterno di prodotto proprietario con licenza componenti network protective
    rule :ExternalService, {:priority => 2},
      [Release, :rel] do |v|
        if v[:rel].product.use.name == "SUE" and
           v[:rel].compatible_license.license_type.protection_level > 2 and
           v[:rel].license.license_type.protection_level < 0
              v[:rel].check_result = false
              v[:rel].errors.add("Licenza e uso del prodotto", "contrastano con la licenza compatibilità componenti.")
        end
      end
      
  
  end
end