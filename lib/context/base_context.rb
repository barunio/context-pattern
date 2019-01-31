require 'rails'
require 'memoizer'

module Context
  class BaseContext
    include Memoizer
    delegate :link_to, to: 'ActionController::Base.helpers'

    class << self
      include Memoizer

      def has_view_helper?(method_name)
        @view_helpers.is_a?(Array) && @view_helpers.include?(method_name.to_sym)
      end

      def view_helpers(*method_names)
        @view_helpers ||= []
        @view_helpers += method_names.map(&:to_sym)
      end

      def wrap(parent_context, **args)
        new(parent_context: parent_context, **args)
      end
    end

    attr_accessor :parent_context

    def initialize(attributes = {})
      attributes.each do |k, v|
        if respond_to?(:"#{k}=")
        then public_send(:"#{k}=", v)
        else raise ArgumentError, "unknown attribute: #{k}"
        end
      end
    end

    def has_view_helper?(method_name)
      self.class.has_view_helper?(method_name) ||
        (@parent_context.present? &&
          @parent_context.has_view_helper?(method_name))
    end

    def method_missing(method_name, *args, &block)
      if @parent_context
        @parent_context.public_send(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @parent_context&.respond_to?(method_name, include_private)
    end
  end
end
