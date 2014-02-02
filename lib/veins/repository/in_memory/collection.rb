module Veins
  class Repository
    module InMemory
      class Collection

        extend Forwardable

        def_delegators :to_a, :count, :empty?

        def initialize
          @index = {}
          @secuence = 0
        end

        def to_a
          @index.values
        end

        def find(id)
          @index[id]
        end

        def create(model)
          model.id = @secuence += 1
          @index[model.id] = model
        end

        def update(model)
          @index[model.id] = model
        end

        def save(model)
          if model.id
            update model
          else
            create model
          end
        end

        def delete(id)
          @index.delete id
        end

        def query(query=nil, &block)
          Queriable.new(QueriableArray.new(to_a), query || block)
        end

      end
    end
  end
end