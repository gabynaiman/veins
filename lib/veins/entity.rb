module Veins
  class Entity

    attr_accessor :id

    def initialize(attributes={})
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to? "#{name}="
      end
    end

  end
end