# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codecom/version'

Gem::Specification.new do |spec|
  spec.name          = 'codecom'
  spec.version       = Codecom::VERSION
  spec.authors       = ['Yassine Zenati']
  spec.email         = ['']
  spec.summary       = %q{This gem automatically generates YARD compatible pre-documentation comments for your beloved methods.}
  spec.description   = %q{This gem automatically generates YARD compatible pre-documentation comments for your beloved methods.}
  spec.homepage      = 'https://github.com/zenati/codecom'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  unless spec.respond_to?(:metadata)
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'bin'
  spec.executables = ['codecom']
  spec.require_paths = ['lib']

  spec.add_dependency 'thor'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
