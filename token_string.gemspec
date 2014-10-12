Gem::Specification.new do |s|
  s.name        = 'token_string'
  s.version     = '0.3.0'
  s.date        = '2014-10-12'
  s.summary     = "TokenString"
  s.description = "Provides a way to deal with CamelCase, snake_case and more in a more elegant way then ActiveSupport::Inflector"
  s.authors     = ["Gyula Laszlo"]
  s.email       = 'gyula.laszlo.gm@gmail.com'
  s.homepage    = 'https://github.com/gyulalaszlo/token_string'
  s.license     = 'MIT'
  s.files = Dir['lib/*.rb']
  s.files += Dir['[A-Z]*'] + Dir['test/**/*']
end
