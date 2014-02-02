require 'coverage_helper'
require 'minitest/autorun'
require 'turn'
require_relative '../app'

Turn.config do |c|
  c.format = :pretty
  c.natural = true
end


module MiniTest::Assertions
  def assert_raises_validation_error(expected_errors)
    yield
    flunk 'ValidationError expected but nothing was raised.'
  rescue ValidationError => ex
    ex.errors.must_equal expected_errors, 'Validation errors'
  end
end

Proc.infect_an_assertion :assert_raises_validation_error, :must_raise_validation_error


class MiniTest::Spec

  let(:repository_adapter) { Veins::Repository::InMemory::Adapter.new }
  let(:repository) { Veins::Repository.new repository_adapter }

  before do
    Veins::UseCase.repository = repository
    AuthenticationService.implementation = FakeAutenticationService.new
  end

end


class FakeAutenticationService
  def authenticate(email, password)
    password == '1234'
  end
end