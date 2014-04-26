module Veins
  module Persistence
    class LazyList < TransparentProxy

      attr_reader :list

      def initialize(adapter, model_class, ref_name, ref_id)
        @adapter = adapter
        @model_class = model_class
        @ref_name = ref_name
        @ref_id = ref_id
      end

      def loaded?
        !@list.nil?
      end

      def reload
        @list = nil
        self
      end

      private

      def __getobj__
        @list ||= @adapter.query(@model_class).where(@ref_name, :==, @ref_id).to_a
      end

    end
  end
end