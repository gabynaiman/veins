module Veins
  class Form
    
    def initialize(params={})
      params.each do |name, value|
        instance_variable_set "@#{name}", value if respond_to? name
      end
    end

    def validate!
      errors = Hash.new { |h,k| h[k] = [] }
      validate errors
      raise ValidationError, errors if errors.any?
    end

  end
end