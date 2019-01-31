module Context
  class Railtie < Rails::Railtie

    initializer 'context-pattern.include_url_helpers_in_base_context' do
      ActiveSupport.on_load :active_record do
        Context::BaseContext.send :include, Rails.application.routes.url_helpers
      end
    end

  end
end
