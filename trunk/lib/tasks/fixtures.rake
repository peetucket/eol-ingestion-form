
namespace :db do
  namespace :fixtures do
    
    ENV["FIXTURE_ORDER"] = 
      %w(users organisms attribute_values).join(' ')
    
    desc "Load ordered fixtures into database"
    task :load_ordered => :environment do
    
      require 'active_record/fixtures'  
    
      ordered_fixtures = Hash.new
      ENV["FIXTURE_ORDER"].split.each { |fx| ordered_fixtures[fx] = nil }
      
      ActiveRecord::Base.establish_connection(ENV['RAILS_ENV'])
      ENV["FIXTURE_ORDER"].split.each do |fixture|
        Fixtures.create_fixtures('test/fixtures',  fixture)
        puts "loading ordered fixture " + fixture
      end unless RAILS_ENV == 'production' 
      
       other_fixtures = Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', '*.{yml,csv}')).collect { |file| File.basename(file, '.*') }.reject {|fx| ordered_fixtures.key? fx }
       other_fixtures.each do |fixture|
        Fixtures.create_fixtures('test/fixtures',  fixture)
        puts "loading remaining fixture " + fixture
      end unless RAILS_ENV == 'production'  
      
      # You really don't want to load your *fixtures* 
      # into your production database, do you?  
    end

    desc 'Create YAML test fixtures from data in an existing database.  
    Defaults to development database.  Set RAILS_ENV to override.'
    task :dump => :environment do
      sql  = "SELECT * FROM %s"
      skip_tables = ["schema_info"]
      ActiveRecord::Base.establish_connection(:development)
      (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
        i = "000"
        File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
          data = ActiveRecord::Base.connection.select_all(sql % table_name)
          file.write data.inject({}) { |hash, record|
            hash["#{table_name}_#{i.succ!}"] = record
            hash
          }.to_yaml
        end
      end
    end

  end
end
