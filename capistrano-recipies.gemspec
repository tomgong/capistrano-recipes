Gem::Specification.new do |s|
  s.name        = 'capistrano-recipies'
  s.version     = '0.0.1'
  s.date        = '2013-01-10'
  s.summary     = "A collection of capistrano recipes for deploying to virtual servers"
  s.description = s.summary
  s.authors     = ["Thomas Winkler, Andreas Happe"]
  s.email       = 'office@starseeders.net'
  s.files       = Dir["lib/**/*.rb", "lib/templates/*", "tasks/*.rake"]
  s.homepage    = 'http://www.starseeders.net'
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README.md"]

  s.add_dependency "capistrano"
  s.add_dependency "capistrano-ext"
end
