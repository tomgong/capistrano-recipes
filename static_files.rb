Capistrano::Configuration.instance.load do
  after "deploy:update_code" do
    raise "test"

    %w(tmp/pids tmp/sockets public/assets public/system log public/uploads).each do |share|
      raise "fut"
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
   
   namespace :debian do
     desc "Install some needed packages"
     task :install_needed_packages do
       run "rvmsudo apt-get install vim-nox git curl build-essential zlib1g-dev libxml2-dev libxslt1-dev libpq-dev libsqlite3-dev"
     end
   end
   
   before "deploy:update_code", "static_files:create_base_directories"
end
