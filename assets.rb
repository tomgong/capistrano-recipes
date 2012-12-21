# only precompiles assets when files inside assets directories change.
# with param :additional_asset_locations you can add additional asset paths
set :asset_locations, ['vendor/assets/','app/assets/','lib/assets/']
set :additional_asset_locations, []
namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      logger.info "Checking asset dirs for precompilation: #{asset_locations.join(" ")} #{additional_asset_locations.join(" ")}"
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} #{asset_locations.join(" ")} #{additional_asset_locations.join(" ")} | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end