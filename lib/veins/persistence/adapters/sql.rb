require 'sequel'

module Veins
  module Persistence
    module Adapters
      class SQL

        attr_reader :mapper, :db
        
        def initialize(mapper, db)
          @mapper = mapper
          @db = db
        end

        def create(model_class, model)
          id = collection(model_class).insert serialize(model)
          model.id = id
        end

        def update(model_class, model)
          collection(model_class).where(id: model.id).update(serialize(model))
        end

        def delete(model_class, id)
          collection(model_class).where(id: id).delete
        end

        def all(model_class)
          collection(model_class).all
        end

        def find(model_class, id)
          data = collection(model_class).where(id: id).first
          raise NotFoundError.new(model_class, id) unless data
          deserialize model_class, data
        end

        private

        def collection(model_class)
          db[mapper.collections[model_class].name]
        end

        def serialize(model_class, model)
          collection(model_class).serialize(model)
        end

        def deserialize(model_class, data)
          collection(model_class).deserialize(model, mapper)
        end

      end
    end
  end
end