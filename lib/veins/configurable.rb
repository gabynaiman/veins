module Veins
  module Configurable

    alias_method :configure, :tap

    def attr_config(name, default_value=nil)
      define_singleton_method name do
        configuration[name.to_sym] || default_value
      end

      define_singleton_method "#{name}=" do |value|
        configuration[name.to_sym] = value
      end
    end

    def reset_configuration
      configuration.clear
    end

    private

    def configuration
      @configuration ||= {}
    end

  end
end