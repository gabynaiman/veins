require 'coverage_helper'
require 'output_helper'
require 'minitest/autorun'

require 'veins'
require 'veins/persistence/adapters/in_memory'

class Model < Module
  def initialize(*attributes)
    define_method :initialize do |params={}|
      params.each do |attr, value|
        public_send "#{attr}=", value
      end
    end

    attributes.each do |name|
      attr_accessor name
    end
  end
end

class Country
  include Model.new :id, :name, :cities
end

class City
  include Model.new :id, :name, :country
end

class CustomAdapter
  def initialize(mapper)
  end
end