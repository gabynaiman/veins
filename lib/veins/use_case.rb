module Veins
  class UseCase

    attr_reader :form

    def initialize(form)
      @form = form
    end

    def run!
      form.validate!
      validate if respond_to? :validate
      run
    end

    def self.run!(params)
      new(form(params)).run!
    end

    private

    def self.form(params)
      puts params
      const_get(:Form).new params
    end

    def repository
      Tenant.current.repository
    end

  end
end