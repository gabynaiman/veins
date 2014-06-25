module Veins
  module Persistence
    class Mapper
      
      attr_reader :collections, :adapters
      
      def initialize(&block)
        @collections = {}
        @adapters = {}
        instance_eval &block if block_given?
      end

      def collection(model_class, options={}, &block)
        Collection.new(model_class, options, &block).tap do |collection|
          collections[model_class] = collection
        end
      end

      def adapter(name, adapter_class, *args)
        adapters[name] = adapter_class.new self, *args
      end

      def adapter_for(model_class)
        adapters[collections[model_class].adapter_name]
      end

      class Collection

        attr_reader :model_class, :options, :attributes, :references, :lists

        def initialize(model_class, options={}, &block)
          @model_class = model_class
          @options = options
          @attributes = []
          @references = []
          @lists = []
          instance_eval &block if block_given?
        end

        def name
          @options[:name] || model_class.name.downcase.gsub('::', '_')
        end

        def adapter(name)
          @adapter_name = name
        end

        def adapter_name
          @adapter_name || :default
        end

        def attribute(name)
          attributes << Attribute.new(name)
        end

        def reference(name, model_class)
          references << Reference.new(name, model_class)
        end

        def list(name, model_class)
          lists << List.new(name, model_class)
        end

        def serialize(model)
          Hash.new.tap do |serialization|
            attributes.each do |attribute|
              serialization[attribute.name] = model.public_send(attribute.name)
            end

            references.each do |reference|
              ref_model = model.public_send reference.name
              serialization["#{reference.name}_id".to_sym] = ref_model ? ref_model.id : nil
            end
          end
        end

        def deserialize(data, mapper)
          model_class.new.tap do |model|
            attributes.each do |attribute|
              model.public_send "#{attribute.name}=", data[attribute.name]
            end

            references.each do |reference|
              ref_id = data["#{reference.name}_id".to_sym]
              if ref_id
                ref_model = LazyModel.new mapper.adapter_for(reference.model_class), reference.model_class, ref_id
                model.public_send "#{reference.name}=", ref_model
              end          
            end

            lists.each do |list|
              model.public_send "#{list.name}=", LazyList.new(mapper.adapter_for(list.model_class), list.model_class, "#{model_class.name.downcase}_id".to_sym, data[:id])
            end
          end
        end

      end

      Attribute = Struct.new :name
      Reference = Struct.new :name, :model_class
      List = Struct.new :name, :model_class
      
    end
  end
end