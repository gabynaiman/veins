module Veins
  module Persistence
    class NotFoundError < StandardError

      attr_reader :model_class, :id

      def initialize(model_class, id)
        @model_class = model_class
        @id = id
      end

      def message
        "#{model_class} #{id} not found"
      end

    end
  end
end