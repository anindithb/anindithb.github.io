# coding: utf-8

Gem::Specification.new do |spec|
    spec.name          = "anindith123"
    spec.version       = "0.5.1"
  
    spec.summary       = %q{A modern, highly customizable, and responsive Jekyll theme for documentation with built-in search.}
    spec.license       = "MIT"
  
    spec.files         = `git ls-files -z ':!:*.jpg' ':!:*.png'`.split("\x0").select { |f| f.match(%r{^(assets|bin|_layouts|_includes|lib|Rakefile|_sass|LICENSE|README|CHANGELOG|favicon)}i) }
    spec.executables   << 'just-the-docs'
  
    spec.add_development_dependency "bundler", ">= 2.3.5"
    spec.add_runtime_dependency "jekyll", ">= 3.8.5"
    spec.add_runtime_dependency "rake", ">= 12.3.1"
  end