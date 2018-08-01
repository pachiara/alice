class LogEntry < ApplicationRecord
require 'csv'

# Licenze
Head_Licenses = ['Utente', 'Licenza', 'Licenza equivalente', 'Operazione', 'Data']
Sel_Licenses = "select user,license,similar_license,operation,date from log_entries where object='license'"

# Legami
Head_Relations = ['Utente', 'Prodotto', 'Release', 'Componente', 'Operazione', 'Data']
Sel_Relations = "select user,product,product_release,component,operation,date from log_entries where object='relation'"

# Componenti
Head_Components = ['Utente', 'Componente', 'Versione', 'Licenza', 'Licenza precedente', 'Proprio', 'Proprio prec.', 'Acquistato', 'Acquist.prec.','Escluso','Escluso prec.','Operazione', 'Data']
Sel_Components = "select user,component, version,license,license_previous,own,own_previous,purchased,purchased_previous,leave_out,leave_out_previous,operation,date from log_entries where object='component'"

# Rilevamenti
Head_Det_components = ['Utente','Prodotto','Release','Rilevamento','Componente','Licenza', 'Licenza precedente', 'Proprio', 'Proprio prec.', 'Acquistato', 'Acquist.prec.','Operazione', 'Data']
Sel_Det_components = "select user,product,'product_release',detection,detected_component,license,license_previous,own,own_previous,purchased,purchased_previous,operation, date from log_entries where object='detected_component' and user<>''"

Selects = {:licenze => {'head' => Head_Licenses, 'sel' => Sel_Licenses, 'file' => 'licenze'},
           :legami => {'head' => Head_Relations, 'sel' => Sel_Relations,'file' => 'legami'},
           :componenti => {'head' => Head_Components, 'sel' => Sel_Components,'file' => 'componenti'},
           :rilevati => {'head' => Head_Det_components, 'sel' => Sel_Det_components, 'file' => 'rilevati'}
          }

  def self.create_csv(kind)
    CSV.open("#{ALICE['alice_logger_path']}#{Selects[kind]['file']}.csv", "wb") do |csv|
      csv << Selects[kind]['head']
      LogEntry.connection.execute(Selects[kind]['sel']).each { |row| csv << row }
    end
  end

  def self.create_entries_from_log
    if LogEntry.exists? or !test('s',"#{ALICE['alice_logger_path']}#{ALICE['alice_logger_name']}")
      puts "Impossibile eseguire: manca il file di partenza o la tabella nel database contiene record"
      return
    end
    entry = nil
    File.open("#{ALICE['alice_logger_path']}#{ALICE['alice_logger_name']}") do |file|
      file.each do |line|
        if line.starts_with?("I, [")
          if entry
            entry.object = kind_of_object(entry)
            entry.save
          end 
          entry = LogEntry.new
          entry.date = line.split('T')[0].split('[')[1] + " " + line.split('T')[1].split('.')[0]
        else
          field = line.split(':')[0].strip
          value = line.split(':')[1].strip
          case field
            when "Created_by"
              entry.user = value
              entry.operation = "C"
            when "Updated_by"
              entry.user = value
              entry.operation = "U"
            when "Destroyed_by"
              entry.user = value
              entry.operation = "D"
            when "Product"
              entry.product = value
            when "Release"
              entry.product_release = value
            when "Detection"
              entry.detection = value
            when "DetectedComponent"
              entry.detected_component = value
            when "Component"
              entry.component = value
            when "Version"
              entry.version = value
            when "License"
              entry.license = value
            when "License previous"
              entry.license_previous = value
            when "Own"
              entry.own = value
            when "Own previous"
              entry.own_previous = value
            when "Purchased"
              entry.purchased = value
            when "Purchased previous"
              entry.purchased_previous = value
            when "Updated_by"
              entry.user = value
            when "Name previous"               
              entry.license_name_previous = value
            when "Similar_License"
              entry.similar_license = value
            when "Similar_License previous"
              entry.similar_license_previous = value
            when "License_type"
              entry.license_type = value
            when "License_type previous"
              entry.license_type_previous = value
            when "Own"
              entry.own = value
            when "Own previous"
              entry.own_previous = value
            when "Purchased"
              entry.purchased = value
            when "Purchased previous"
              entry.purchased_previous = value
            when "Leave_out"
              entry.leave_out = value
            when "Leave_out previous"
              entry.leave_out_previous = value
          end
        end
      end
    end
    entry.object = kind_of_object(entry)
    entry.save
  end

  def self.kind_of_object(entry)
    if entry.detected_component
      return "detected_component"
    end
    if entry.component
      if entry.version
        return "component"
      else
        return "relation"
      end
    end
    if entry.license and !entry.product and !entry.component
      return "license"
    end
  end  
 
end

