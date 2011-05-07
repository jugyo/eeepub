# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "eeepub"
  s.version     = "0.6.1"
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

  s.add_runtime_dependency(%q<zipruby>, ["~> 0.3"])
  s.add_runtime_dependency(%q<builder>, ["~> 3.0"])
  s.add_development_dependency(%q<rspec>, ["~> 2.0"])
  s.add_development_dependency(%q<rr>, ["~> 1.0"])
  s.add_development_dependency(%q<simplecov>, ["~> 0.4"])
  s.add_development_dependency(%q<nokogiri>, ["~> 1.4"])
end
