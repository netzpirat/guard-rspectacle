# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'guard/rspectacle/version'

Gem::Specification.new do |s|
  s.name        = 'guard-rspectacle'
  s.version     = Guard::RSpectacleVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Michael Kessler']
  s.email       = ['michi@netzpiraten.ch']
  s.homepage    = 'http://github.com/netzpirat/guard-rspectacle'
  s.summary     = 'Guard gem for RSpec testing'
  s.description = 'Guard::RSpectacle automatically tests your code with RSpec'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project = 'guard-rspec'

  s.add_dependency 'guard', '>= 1.1.0'
  s.add_dependency 'rspec', '>= 2.8.0'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'kramdown'

  s.files        = Dir.glob('{bin,lib}/**/*') + %w[LICENSE README.md]
  s.require_path = 'lib'
end
