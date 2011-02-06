# -*- coding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'eeepub/version'

spec = Gem::Specification.new do |gem|
  gem.name        = "eeepub"
  gem.version     = EeePub::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.summary     = %Q{ePub generator}
  gem.description = %Q{EeePub is a Ruby ePub generator.}
  gem.email       = ["jugyo.org@gmail.com", "seb@cine7.net"]
  gem.homepage    = "http://github.com/jugyo/eeepub"
  gem.authors     = ["jugyo", "Sébastien Cevey"]
  gem.files       = Dir.glob("lib/**/*") + %w(LICENSE README.md)
  gem.add_dependency "builder"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rr"
end

