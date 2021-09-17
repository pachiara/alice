namespace :alice do
  
  desc "dump default data"
  task :dump_default_data => :environment do
    puts "Estrazione dei dati per il caricamento di default dal db di environment #{Rails.env}"
    puts SeedDump.dump(User.limit(1), file: 'db/seeds.rb')
    ENV['MODELS']="Category,LicenseType,License,Use,Rule,RuleEntry,Component"
    ENV['WITH_ID']='true' 
    ENV['FILE']="db/seeds.rb"    
    ENV['APPEND']="true"
    Rake::Task["db:seed:dump"].invoke(ENV['MODELS'],ENV['WITH_ID'],ENV['FILE'])
  end
  
end