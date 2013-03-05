# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "eeepub"
  s.version     = "0.8.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["jugyo"]
  s.email       = ["jugyo.org@gmail.com"]
  s.homepage    = "http://github.com/jugyo/eeepub"
  s.summary     = %q{ePub generator}
  s.description = %q{EeePub is a Ruby ePub generator.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "builder"
  s.add_dependency "rubyzip"
  s.add_development_dependency "rspec"
  s.add_development_dependency "nokogiri"
  s.add_development_dependency "rr"
  s.add_development_dependency "simplecov"  
end
