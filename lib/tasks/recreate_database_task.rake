namespace :db do
  
  desc "Drop then recreate the dev database, migrate up, and load fixtures" 
  task :remigrate => :environment do
    return unless %w[development test staging].include? RAILS_ENV
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.connection.recreate_database ActiveRecord::Base.connection.current_database
    ActiveRecord::Base.establish_connection
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:fixtures:load_ordered"].invoke
  end

end
