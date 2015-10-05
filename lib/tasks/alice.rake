namespace :alice do
  
  desc "dump default data"
  task :dump_default_data => :environment do
    puts "Estrazione dei dati per il caricamento di default dal db di environment #{Rails.env}"
    ENV['MODELS']="User,Admin,Category,LicenseType,License,Use,Rule,RuleEntry,Component" 
    ENV['WITH_ID']='true' 
    ENV['FILE']="db/seeds.rb"    
    Rake::Task["db:seed:dump"].invoke(ENV['MODELS'],ENV['WITH_ID'],ENV['FILE'])
  end
  
end
