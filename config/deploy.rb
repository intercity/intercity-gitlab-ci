require 'bundler/capistrano'
require 'intercity/capistrano'

set :application, "gitlab_production"
set :repository,  "https://github.com/gitlabhq/githlab-ci.git"
set :branch, "3-2-stable"

set :deploy_via, :remote_cache
set :scm, :git
set :user, "deploy"
set :bundle_without, [:development, :test, :puma, :postgres, :aws]

server "<server host>", :web, :app, :db, :primary => true

after "deploy:restart", "deploy:cleanup"

after "deploy:finalize_update", "gitlab_ci:link"

namespace :gitlab_ci do

  desc "Upload gitlab.yml and create gitlabl satellites directory."
  task :configure do
    upload "application.yml", "/u/apps/#{application}/shared/config"
  end

  task :link do
    run "#{try_sudo} ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
  end

  desc "Executes bundle exec  rake gitlab:setup."
  task :setup do
    run "cd #{current_path} && bundle exec rake gitlab:setup RAILS_ENV=production force=yes"
  end

end
