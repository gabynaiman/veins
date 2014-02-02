module Veins
  class Tenant
  
    extend Veins::Configurable

    attr_config :repository_adapter_class

    @tenants = {}

    def self.current
      Thread.current[:tenant]
    end

    def self.use(name)
      Thread.current[:tenant] = @tenants[name] ||= new(name, Veins::Repository.new(repository_adapter_class.new))
    end

    attr_reader :name, :repository

    def initialize(name, repository)
      @name = name
      @repository = repository
    end

  end
end