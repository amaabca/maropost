# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'maropost/version'

Gem::Specification.new do |spec|
  spec.name = 'maropost'
  spec.version = Maropost::VERSION
  spec.authors = [
    'Michael van den Beuken',
    'Ruben Estevez',
    'Darko Dosenovic',
    'Zoie Carnegie',
    'Sinead Errity'
  ]
  spec.email = [
    'michael.beuken@gmail.com',
    'ruben.a.estevez@gmail.com',
    'darko.dosenovic@ama.ab.ca',
    'zoie.carnegie@ama.ab.ca',
    'sinead.errity@ama.ab.ca'
  ]
  spec.summary = 'Interact with the Maropost API'
  spec.description = 'Interact with the Maropost API'
  spec.homepage = 'https://github.com/amaabca/maropost'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})

  spec.bindir = 'bin'
  spec.require_paths = %w[lib spec]

  spec.add_dependency 'rest-client'
  spec.add_dependency 'rest-client-jogger'
  spec.add_dependency 'activesupport'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'rubocop', '0.49.1'
  spec.add_development_dependency 'pry'

  spec.required_ruby_version = '>= 2.2'
end
