module Context
  module BaseContextHelper
    def method_missing(method_name, *args, &block)
        if context && context.has_view_helper?(method_name)
        context.public_send(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, _include_private = false)
      context.has_view_helper?(method_name)
    end
  end
end
