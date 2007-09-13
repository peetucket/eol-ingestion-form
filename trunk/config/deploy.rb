require 'mongrel_cluster/recipes'
require 'palmtree/recipes/mongrel_cluster'

set :application, "eol_ingestion_form"

set :svn_user, ENV['svn_user'] || "svn_user"
set :svn_password, Proc.new { Capistrano::CLI.password_prompt('SVN Password: ') }
set :repository,
            Proc.new { "--username #{svn_user} " +
                       "--password #{svn_password} " +
                       "svn://repository" }

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

set :deploy_to, "/data/www/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, ""
role :web, ""
role :db,  "", :primary => true