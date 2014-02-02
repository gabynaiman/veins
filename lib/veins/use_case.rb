module Veins
  class UseCase

    extend Configurable

    attr_config :repository

    attr_reader :form

    def initialize(form)
      @form = form
    end

    def self.run!(form)
      new(form).run!
    end

    def run!
      form.validate!
      validate if respond_to? :validate
      run
    end

    private

    def repository
      UseCase.repository
    end

  end
end