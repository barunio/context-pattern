# Changelog

## [Unreleased]
* Fix naming bug in BaseContextHelper

## [1.1.0]
* Add method_missing logic to Context::Controller, so that controllers can
  easily access public methods in the context chain
* Add BaseContextHelper module, which is used to provide views access to
  view_helpers defined in the context chain
* Fix gem dependencies in this gemfile
* Add README file
* Add this changelog

## [1.0.0]
* Prevent contexts from overriding public methods already available in the
  context chain

## [0.2.0]
* Add specs for BaseContext
* Add the introspection methods to BaseContext:
  #context_chain_class, #context_method_mapping, and #whereis
* Add BaseContext.decorate interface

## [0.1.0]
* Initial code ported from the WegoWise app
