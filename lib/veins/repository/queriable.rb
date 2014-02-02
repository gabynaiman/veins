module Veins
  class Repository
    class Queriable

      include Enumerable

      def initialize(queriable, query=nil, &block)
        @queriable = queriable
        @query = query || block
      end

      def query(query=nil, &block)
        Queriable.new self, query || block
      end

      def to_a
        @query.call(@queriable).to_a
      end

      def each(&block)
        to_a.each &block
      end

    end
  end
end