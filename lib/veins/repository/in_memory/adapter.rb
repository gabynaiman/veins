module Veins
  class Repository
    module InMemory
      class Adapter

        def initialize
          @collections = Hash.new { |h,k| h[k] = Collection.new }
        end

        def [](collection)
          @collections[collection]
        end

      end

    end
  end
end