require_relative 'context/base_context'
require_relative 'context/controller'

if defined?(Rails)
  require_relative 'context/railtie'
  require_relative 'context/base_context_helper'
end
