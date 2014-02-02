module Veins
  class Repository

    attr_reader :adapter

    def initialize(adapter)
      @adapter = adapter
    end

    def [](collection_name)
      adapter[collection_name]
    end

  end
end