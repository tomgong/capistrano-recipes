Capistrano::Configuration.instance(:must_exist).load do
  namespace :static_directories do
    task :create_shared_directories do
      %w(tmp/pids tmp/sockets public/assets public/spree public/system log public/uploads).each do |share|
        run "if [ -L #{release_path}/#{share} ]; then rm -f #{release_path}}/#{share} ; fi"
        run "if [ ! -d #{shared_path}/#{share} ]; then mkdir -p #{shared_path}/#{share} ; fi"
        run "ln -s -f #{shared_path}/#{share} #{release_path}/#{share}"
      end
    end
    after "deploy:update_code", "static_directories:create_shared_directories"

    desc "Create some directories"
    task :create_base_directories do
      run "mkdir -p #{deploy_to}/releases"
    end
    before "deploy:update_code", "static_directories:create_base_directories"
  end
end