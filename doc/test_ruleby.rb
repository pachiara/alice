$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib/')
require 'ruleby'

include Ruleby

class Product
  def initialize(name,license,use)
    @name    = name
    @license = license
    @use     = use
    @status  = :New
  end
  attr :status, true
  attr_reader :name,:license,:use
  def to_s
    return '[Prodotto: ' + @name.to_s + ' Licenza: ' + @license.to_s + ' Uso: ' + @use.to_s + ']';
  end
end

class Component
  def initialize(name,license,use)
    @name    = name
    @license = license
    @use     = use
    @status  = :New
  end
  attr :status, true
  attr_reader :name,:license,:use
  def to_s
    return '[Componente: ' + @name.to_s + ' Licenza: ' + @license.to_s + ' Uso: ' + @use.to_s + ']';
  end
end

class LicenseRulebook < Rulebook
  def rules
  
    # Nuovo prodotto
    rule :New, {:priority => 10}, 
      [Product, :p] do |vars|
        puts 'Prodotto : ' + vars[:p].to_s
    end

    # Licenza Permissiva
    rule :Permit,
      [Product, :p, m.use == "SUE", m.license == "P"],
      [Component,:c, m.use == "LS", m.license == "OP", m.status == :New] do |vars|
        vars[:c].status = :Ok
        modify vars[:c]
    end

    # Licenza Leggera
    rule :Lesser,
      [Product, :p, m.use == "SUE", m.license == "P"],
      [Component,:c, m.use == "LS", m.license == "OL", m.status == :New] do |vars|
        vars[:c].status = :Ok
        modify vars[:c]
    end

    # Licenza Forte
    rule :Strong,
      [Product, :p, m.use == "SUE", m.license == "P"],
      [Component,:c, m.use == "LS", m.license == "OS", m.status == :New] do |vars|
        vars[:c].status = :Ko
        modify vars[:c]
    end
    
    rule :Ok,
      [Product, :p],
      [Component, :c, m.status == :Ok] do |vars|
        puts 'Licenza compattibile : ' + vars[:c].to_s    
    end
    
    rule :Ko,
      [Product, :p],
      [Component, :c, m.status == :Ko] do |vars|
        puts 'Licenza incompattibile : ' + vars[:c].to_s    
    end
  end
end

# FACTS

p = Product.new('Siarl', 'P', 'SUE') # licenza=P(proprietaria),uso=SUE(servizzio utenti esterni) 

c1 = Component.new('Hibernate','OP', 'LS') # p (prodotto), licenza=OP (osi permissiva), uso=LD (link dinamico)
c2 = Component.new('Common', 'OL', 'LS') # p (prodotto), licenza=OP (osi permissiva), uso=LD (link dinamico)
c3 = Component.new('aaa', 'OP', 'LS') # p (prodotto), licenza=OP (osi permissiva), uso=LD (link dinamico)
c4 = Component.new('bbbooooo', 'OP', 'LS') # p (prodotto), licenza=OP (osi permissiva), uso=LD (link dinamico))

engine :engine do |e|
  LicenseRulebook.new(e).rules
  e.assert p
  e.assert c1
  e.assert c2
  e.assert c3
  e.assert c4
  e.match
end