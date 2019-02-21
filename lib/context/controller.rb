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
  end
end
