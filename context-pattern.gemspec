# -*- encoding: utf-8 -*-
require 'rubygems' unless defined? Gem
require File.dirname(__FILE__) + "/lib/context/version"

Gem::Specification.new do |s|
  s.name = "context-pattern"
  s.version = Context::VERSION
  s.authors = ["Barun Singh"]
  s.email = "bsingh@wegowise.com"
  s.homepage = "http://github.com/barunio/context-pattern"
  s.summary = "Start using the Context Pattern in your Rails app"
  s.description = "Start using the Context Pattern in your Rails app"
  s.required_rubygems_version = ">= 1.3.6"
  s.files = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.extra_rdoc_files = ["README.md", "LICENSE.txt"]
  s.license = 'MIT'

  s.add_dependency('rails', '>= 4.0')
  s.add_dependency('memoizer')

  s.add_development_dependency('rspec', '~> 3.0')
  s.add_development_dependency('rake', '>= 10.4')
end
