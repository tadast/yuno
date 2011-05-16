# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "yuno"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tadas Tamosauskas"]
  s.email       = ["tadas@pdfcv.com"]
  s.homepage    = ""
  s.executables = "yuno"
  s.summary     = %q{Y-U-NO generator}
  s.description = %q{Y-U-NO meme cmd line generator}

  s.rubyforge_project = "yuno"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "bin"]
end
