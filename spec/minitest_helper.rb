require 'coverage_helper'
require 'minitest/autorun'
require 'turn'
require 'veins'

Turn.config do |c|
  c.format = :pretty
  c.natural = true
end

class User
  attr_accessor :id
  attr_accessor :name

  def initialize(attributes={})
    @id = attributes[:id]
    @name = attributes[:name]
  end
end