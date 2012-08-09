Capistrano::Configuration.instance.load do

  before 'deploy:restart', 'barista:brew'

  _cset(:barista_role) { :app }

  namespace :barista do
    desc 'Compile CoffeeScripts.'
    task :brew, :roles => lambda { fetch(:barista_role) } do
      rails_env = fetch(:rails_env, "production")
      run("cd #{current_path} ; RAILS_ENV=#{rails_env} bundle exec rake barista:brew")
    end
  end
end

