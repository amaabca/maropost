# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'maropost/version'

Gem::Specification.new do |spec|
  spec.name          = "maropost"
  spec.version       = Maropost::VERSION
  spec.authors       = ["Michael van den Beuken", "Ruben Estevez", "Jordan Babe", "Mathieu Gilbert", "Ryan Jones", "Darko Dosenovic", "Jonathan Weyermann", "Adam Melnyk", "Kayt Campbell", "Kathleen Robertson", "Jesse Doyle", "Sinead Errity"]
  spec.email         = ["michael.beuken@gmail.com", "ruben.a.estevez@gmail.com", "jorbabe@gmail.com", "mathieu.gilbert@ama.ab.ca", "ryan.michael.jones@gmail.com", "darko.dosenovic@ama.ab.ca", "jonathan.weyermann@ama.ab.ca", "adam.melnyk@ama.ab.ca", "kayt.campbell@ama.ab.ca", "kathleen.robertson@ama.ab.ca", "jdoyle@ualberta.ca", "sinead.errity@ama.ab.ca"]
  spec.summary       = %q{Interact with the Maropost API}
  spec.description   = %q{Interact with the Maropost API}
  spec.homepage      = "https://github.com/amaabca/maropost"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
