module Context
  module Controller
    def self.included(base)
      base.send(:prepend_before_action, :__set_base_context)
    end

    def extend_context(context, **args)
    context_class = "#{context}Context".constantize
    @__context = context_class.wrap(@__context, **args)
    end

    def __set_base_context
      @__context = Context::BaseContext.new
    end

    private

    def method_missing(method_name, *args, &block)
      if @__context.respond_to?(method_name)
        @__context.public_send(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @__context.respond_to?(method_name, include_private)
    end
  end
end
