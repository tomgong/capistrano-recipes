Capistrano::Configuration.instance.load do
  task :after_update_code do
    %w(tmp/pids tmp/sockets public/assets public/system).each do |share|
      run "if [ ! -d #{shared_path}/#{share} ]; then mkdir -p #{shared_path}/#{share} ; fi"
      run "ln -s -f #{shared_path}/#{share} #{release_path}/#{share}"
    end
  end
  
  namespace :static_files do
     desc "Create some directories"
     task :create_base_directories do
       run "rvmsudo mkdir -p /media/raid/managed-apps/#{application}/releases"
     end
   end
   
   before "deploy:update_code", "static_files:create_base_directories"
end