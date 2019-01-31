module Context
  module Controller
    def self.included(base)
      base.send(:prepend_before_action, :__set_base_context)
    end

    def extend_context(context, **args)
    context_class = "#{context}Context".constantize
    @context = context_class.wrap(@context, **args)
    end

    def __set_base_context
      @context = Context::BaseContext.new
    end
  end
end
