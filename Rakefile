# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

task :model_specs do
  system('bundle exec rspec spec/models')
end

task :request_specs do
  system('bundle exec rspec spec/request')
end

task :views_specs do
  system('bundle exec rspec spec/views')
end

task :ui_specs do
  system('bundle exec rspec spec/ui')
end
