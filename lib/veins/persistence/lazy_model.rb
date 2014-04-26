module Veins
  module Persistence
    class LazyModel < TransparentProxy

      attr_reader :id
      
      def initialize(adapter, model_class, id)
        @adapter = adapter
        @model_class = model_class
        @id = id
      end

      def loaded?
        !@model.nil?
      end

      def reload
        @model = nil
        self
      end

      private

      def __getobj__
        @model ||= @adapter.find @model_class, id
      end

    end
  end
end