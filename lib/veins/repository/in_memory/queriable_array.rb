module Veins
  class Repository
    module InMemory
      class QueriableArray < SimpleDelegator

        def query(query=nil, &block)
          Queriable.new self, query || block
        end

      end
    end
  end
end