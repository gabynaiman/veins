module Veins
  module Persistence
    class Mapper
      
      attr_reader :collections, :adapters
      
      def initialize(&block)
        @collections = {}
        @adapters = {}
        instance_eval &block if block_given?
      end

      def collection(model_class, &block)
        Collection.new(model_class, &block).tap do |collection|
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

        attr_reader :model_class, :attributes, :references, :lists

        def initialize(model_class, &block)
          @model_class = model_class
          @attributes = []
          @references = []
          @lists = []
          instance_eval &block if block_given?
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

      end

      Attribute = Struct.new :name
      Reference = Struct.new :name, :model_class
      List = Struct.new :name, :model_class
      
    end
  end
end