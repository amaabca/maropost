# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'maropost/version'

Gem::Specification.new do |spec|
  spec.name          = 'maropost'
  spec.version       = Maropost::VERSION
  spec.authors       = ['Michael van den Beuken', 'Ruben Estevez', 'Jordan Babe', 'Mathieu Gilbert', 'Ryan Jones', 'Darko Dosenovic', 'Jonathan Weyermann', 'Adam Melnyk', 'Kayt Campbell', 'Kathleen Robertson', 'Jesse Doyle', 'Sinead Errity', 'Serene Yew', 'Martin Echtner']
  spec.email         = ['michael.beuken@gmail.com', 'ruben.a.estevez@gmail.com', 'jorbabe@gmail.com', 'mathieu.gilbert@ama.ab.ca', 'ryan.michael.jones@gmail.com', 'darko.dosenovic@ama.ab.ca', 'jonathan.weyermann@ama.ab.ca', 'adam.melnyk@ama.ab.ca', 'kayt.campbell@ama.ab.ca', 'kathleen.robertson@ama.ab.ca', 'jdoyle@ualberta.ca', 'sinead.errity@ama.ab.ca', 'serene.yew@ama.ab.ca', 'martin.echtner@ama.ab.ca']
  spec.summary       = %q{Interact with the Maropost API}
  spec.description   = %q{Interact with the Maropost API}
  spec.homepage      = 'https://github.com/amaabca/maropost'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib spec)

  spec.add_dependency 'rest-client'

  spec.required_ruby_version = '>= 2.4'
end
