require File.expand_path("../.gemspec", __FILE__)
require File.expand_path("../lib/ultimaker/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name     = "ultimaker"
  gem.authors  = ["Samuel Kadolph"]
  gem.email    = ["samuel@kadolph.com"]
  gem.summary  = readme.summary
  gem.homepage = "https://github.com/samuelkadolph/ultimaker"
  gem.license  = "MIT"
  gem.version  = Ultimaker::VERSION

  gem.files = Dir["lib/**/*"].reject { |f| f =~ /discovery/ }

  gem.required_ruby_version = ">= 2.0"
end
