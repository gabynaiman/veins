module Veins
  module Persistence
    module Adapters
      class InMemory

        attr_reader :mapper, :sequences, :collections

        def initialize(mapper)
          @mapper = mapper
          @sequences = {}
          @collections = {}

          mapper.collections.keys.each do |collection|
            @sequences[collection] = 0
            @collections[collection] = {}
          end
        end

        def create(model_class, model)
          model.id = next_id model_class
          persist model_class, model
        end

        def update(model_class, model)
          persist model_class, model
        end

        def delete(model_class, id)
          collections[model_class].delete id
        end

        def all(model_class)
          collections[model_class].values.map do |data| 
            deserialize model_class, data
          end
        end

        def find(model_class, id)
          data = collections[model_class][id]
          raise NotFoundError.new(model_class, id) unless data
          deserialize model_class, data
        end

        def query(model_class)
          Query.new self, model_class
        end

        def execute(query)
          collections[query.model_class].values.select do |data|
            query.conditions.inject(true) do |bool, condition|
              data[condition.attribute].public_send(condition.operator, condition.value)
            end
          end.sort do |a,b|
            bits = query.orders.map do |order|
              if order.asc?
                a[order.attribute] <=> b[order.attribute]
              else
                b[order.attribute] <=> a[order.attribute]
              end
            end
            bits.detect { |e| e != 0 } || 0
          end.map do |data|
            deserialize query.model_class, data
          end
        end

        private

        def next_id(model_class)
          sequences[model_class] += 1
        end

        def persist(model_class, model)
          collections[model.class][model.id] = serialize model
        end

        def serialize(model)
          Hash.new.tap do |serialization|
            collection = mapper.collections[model.class]

            collection.attributes.each do |attribute|
              serialization[attribute.name] = model.public_send(attribute.name)
            end

            collection.references.each do |reference|
              ref_model = model.public_send reference.name
              serialization["#{reference.name}_id".to_sym] = ref_model ? ref_model.id : nil
            end
          end
        end

        def deserialize(model_class, data)
          model_class.new.tap do |model|
            collection = mapper.collections[model_class]

            collection.attributes.each do |attribute|
              model.public_send "#{attribute.name}=", data[attribute.name]
            end

            collection.references.each do |reference|
              ref_id = data["#{reference.name}_id".to_sym]
              if ref_id
                ref_model = LazyModel.new mapper.adapter_for(reference.model_class), reference.model_class, ref_id
                model.public_send "#{reference.name}=", ref_model
              end          
            end

            collection.lists.each do |list|
              model.public_send "#{list.name}=", LazyList.new(mapper.adapter_for(list.model_class), list.model_class, "#{model_class.name.downcase}_id".to_sym, data[:id])
            end
          end
        end

      end
    end
  end
end