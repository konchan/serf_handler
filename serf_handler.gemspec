# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'serf_handler'

Gem::Specification.new do |gem|
  gem.name        = 'serf_handler'
  gem.version     = '0.2.1'
  gem.authors     = ['KONNO Katsuyuki']
  gem.email       = 'konno.katsuyuki@nifty.com'
  gem.description = 'Serf event handler for ruby'
  gem.summary     = 'Serf event handler for ruby'
  gem.homepage    = 'http://github.com/konchan/serf_handler'
  gem.licenses    = ['MIT']

  gem.rubygems_version = '2.0.14'
  gem.files            = `git ls-files`.split($\)
  gem.executables      = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files       = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths    = ['lib']
  gem.extra_rdoc_files = [
    'LICENSE',
    'README.md'
  ]

  gem.add_runtime_dependency('logger')
end
