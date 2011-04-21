# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rollable/version"

Gem::Specification.new do |s|
  s.name        = "rollable"
  s.version     = Rollable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Timon Vonk"]
  s.email       = ["mail@timonv.nl"]
  s.homepage    = "http://www.timonv.nl"
  s.summary     = %q{Agnostic roles for rails}
  s.description = %q{This gem adds agnostic roles for authorization to Rails.}

  s.rubyforge_project = "rollable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "rails", "~> 3.0.7"
  s.add_dependency "rspec"
end
