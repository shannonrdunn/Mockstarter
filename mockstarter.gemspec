# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mockstarter/version'

Gem::Specification.new do |spec|
  spec.name          = "mockstarter"
  spec.version       = Mockstarter::VERSION
  spec.authors       = ["Shannon Dunn"]
  spec.email         = ["shannonrdunn@gmail.com"]

  spec.summary       = %q{cli mock of kickstarter}
  spec.description   = %q{Create projects, fund projects, simply}
  spec.homepage      = "https://github.com/shannonrdunn/Mockstarter"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "redis"
  spec.add_runtime_dependency "thor"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mock_redis"

end
