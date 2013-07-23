require 'ruleby'
include Ruleby

class LicenseRulebook < Rulebook
  
  # Vedi http://www.dwheeler.com/essays/floss-license-slide.html
  Floss_slide = {
    "public" => ["public", "mit", "bsd", "apache", "lgplv21", "lgplv21+", "lgplv3", "lpglv3+", "gplv2", "gplv2+", "gplv3", "gplv3+", "afferogplv3", "mpl11"],
    "mit" => ["mit", "bsd", "apache", "lgplv21", "lgplv21+", "lgplv3", "lpglv3+", "gplv2", "gplv2+", "gplv3", "gplv3+", "afferogplv3", "mpl11"],
    "bsd" => ["bsd", "apache", "lgplv21", "lgplv21+", "lgplv3", "lpglv3+", "gplv2", "gplv2+", "gplv3", "gplv3+", "afferogplv3", "mpl11"],
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

  # -1 Proprietary, 0 = Permissive, 1 = Weakly Protective, 2 = Strongly Protective, 3 = Network Protective
  Protection_levels = { "copyright" => -1,
     "public" => 0, "mit" => 0, "bsd" => 0, "apache" => 0,
     "lgplv21" => 1,"lgplv21+" => 1, "lgplv3" => 1, "lpglv3+" => 1, "mpl11" => 1,
     "gplv2" => 2, "gplv2+" => 2, "gplv3" => 2, "gplv3+" => 2,
     "afferogplv3" => 3    
  }

  def search_compatible(license1, license2)
    compatibles = Floss_slide[license1] & Floss_slide[license2]
    return compatibles ? compatibles[0] : nil 
  end
  
  def rules
    
    # Inizializzazione
    rule :New, {:priority => 10}, 
      [Product, :prod] do |v|
        v[:prod].compatible_license = "public"
        v[:prod].result = true
    end
    
=begin    
    # Prodotto proprietario e componente con licenza strong
    rule :Strong, {:priority => 5},
      [Product, :prod],
      [Component,:comp ] do |v|
        puts v[:comp].name
        if Protection_levels[v[:comp].license.name] > 1 and Protection_levels[v[:prod].license.name] < 0 
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
        new_compatible_license = self.search_compatible(v[:prod].compatible_license, v[:comp].license.name)
        if new_compatible_license == nil 
          v[:prod].result = false
          error_string = "#{v[:comp].name} licenza #{v[:comp].license.name} " +
                         "incompatibile con licenza: #{v[:prod].compatible_license}"
          v[:prod].errors.add("Componente: ", "#{error_string}")
        elsif v[:prod].compatible_license != new_compatible_license
          v[:prod].compatible_license = new_compatible_license
        end
    end
  
    # Prodotto proprietario e licenza richiesta strong
    rule :Strong, {:priority => 2},
      [Product, :prod] do |v|
        if Protection_levels[v[:prod].compatible_license] > 1 and Protection_levels[v[:prod].license.name] < 0 
          v[:prod].result = false
          v[:prod].errors.add(:license_id, "incompatibile con licenza richiesta dai componenti.")
        end    
    end
    
    rule :Sentenza, {:priority => 1}, 
      [Product, :prod] do |v|
        if v[:prod].result == false
#          v[:prod].compatible_license = nil
        end
    end
    
  end
end