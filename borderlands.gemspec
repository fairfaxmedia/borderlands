# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'borderlands/version'

Gem::Specification.new do |spec|
  spec.name          = "borderlands"
  spec.version       = Borderlands::VERSION
  spec.authors       = ["John Slee"]
  spec.email         = ["john.slee@fairfaxmedia.com.au"]

  spec.summary       = %q{Conduct assorted Akamai CDN audit tasks}
  spec.description   = %q{Conduct assorted audit tasks on an Akamai CDN account, using the Property Manager API}
  spec.homepage      = "https://github.com/fairfaxmedia/borderlands"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor", "~> 0.19"
  spec.add_runtime_dependency "inifile", "~> 3"
  spec.add_runtime_dependency "akamai-edgegrid", "~> 1"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end
