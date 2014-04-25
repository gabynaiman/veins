module Veins
  module Persistence
    class Query

      include Enumerable

      attr_reader :adapter, :model_class, :conditions, :orders

      def initialize(adapter, model_class)
        @adapter = adapter
        @model_class = model_class
        @conditions = []
        @orders = []
      end

      def where(attribute, operator, value)
        conditions << Condition.new(attribute, operator, value)
        self
      end

      def order(attribute, direction=:asc)
        orders << Order.new(attribute, direction)
        self
      end

      def each(&block)
        execute.each &block
      end

      private

      def execute
        adapter.execute self
      end

      Condition = Struct.new :attribute, :operator, :value
      
      Order = Struct.new :attribute, :direction do
        def asc?
          direction == :asc?
        end
      end

    end
  end
end