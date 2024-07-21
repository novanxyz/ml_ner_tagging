
lock "~> 3.11.0"
set :application, 'backoffice-migrate'
set :rvm_ruby_version, '2.5.1@backoffice-migrate'

set :repo_url, 'git@github.com:kadriansyah/backoffice-migrate.git'
set :branch, 'master'

set :user,  '<ssh user>'
set :use_sudo,  false
set :ssh_options,   { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }

# for staging, use development environment
if fetch(:stage) == 'staging'
  set :rails_env, :development
else
  set :rails_env, fetch(:stage)
end

set :deploy_to, "/var/www/html/#{fetch(:application)}"

# how many old releases do we want to keep
set :keep_releases, 3

# # There is a known bug that prevents sidekiq from starting when pty is true on Capistrano 3.
# set :pty, false

# files we want symlinking to specific entries in shared
set :linked_files, fetch(:linked_files, []).push('config/application.yml', 'config/mongoid.yml', 'config/secrets.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Passenger
set :passenger_roles, :app
set :passenger_restart_runner, :sequence
set :passenger_restart_wait, 5
set :passenger_restart_limit, 2
set :passenger_restart_with_sudo, false
# set :passenger_environment_variables, {}
set :passenger_restart_command, 'passenger-config restart-app'
set :passenger_restart_options, -> { "#{deploy_to} --ignore-app-not-running" }

# # Sidekiq
# set :sidekiq_config, -> { File.join(shared_path, 'config', 'sidekiq.yml') }






































