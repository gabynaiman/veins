require 'generic_visitor'

module Condition

 class Equal

    attr_reader :attribute, :value
    
    def initialize(attribute, value)
      @attribute = attribute
      @value = value
      @negated = false
    end

    def negate
      self.dup.negate!
    end

    def negate!
      @negated = true
      self
    end

    def negated?
      @negated
    end

  end

  class Negation

    attr_reader :condition
    
    def initialize(condition=nil)
      @condition = condition
      yield self if block_given?
    end

    def equal(*args)
      @condition = Equal.new(*args).negate
    end

  end

  class Coordinator

    attr_reader :conditions

    def initialize(*conditions)
      @conditions = conditions
      yield self if block_given?
    end

    def equal(*args)
      conditions << Equal.new(*args)
    end

    def not(*args, &block)
      conditions << Negation.new(*args, &block)
    end

    def or(*args, &block)
      conditions << Any.new(*args, &block)
    end

    def and(*args, &block)
      conditions << All.new(*args, &block)
    end

  end

  Any = Class.new Coordinator
  All = Class.new Coordinator

end

class Order

  attr_reader :attributes

  def initialize(*attributes)
    @attributes = attributes
    yield self if block_given?
  end

  def asc(attribute)
    attributes << Asc.new(attribute)
  end

  def desc(attribute)
    attributes << Desc.new(attribute)
  end

  Asc = Struct.new :attribute
  Desc = Struct.new :attribute

end

class Query

  attr_reader :collection, :condition, :order

  def initialize(collection)
    @collection = collection
    yield self if block_given?
  end

  def where(condition=nil, &block)
    @condition = condition || Condition::All.new(&block)
  end

  def order(*attributes, &block)
    return @order if attributes.empty? && block.nil?
    @order = Order.new *attributes, &block
  end

end


class ToSql < GenericVisitor::Visitor

  visitor_for Query do |query|
    sections = ["SELECT *", "FROM #{query.collection}"]
    sections << "WHERE #{query.condition.accept(self)}" if query.condition
    sections << "ORDER BY #{query.order.accept(self)}" if query.order
    sections.join("\n\t")
  end

  visitor_for Condition::Equal do |equal|
    "#{equal.attribute} #{equal.negated? ? '<>' : '='} #{equal.value.accept self}"
  end

  visitor_for Condition::Negation do |negate|
    negate.condition.negate.accept self
  end

  visitor_for Condition::Any do |any|
    "(#{any.conditions.map { |c| c.accept self }.join(' OR ')})"
  end  

  visitor_for Condition::All do |all|
    "(#{all.conditions.map { |c| c.accept self }.join(' AND ')})"
  end

  visitor_for Order do |order|
    order.attributes.map { |a| a.accept self }.join(', ')
  end

  visitor_for Order::Asc do |asc|
    asc.attribute
  end

  visitor_for Order::Desc do |desc|
    "#{desc.attribute} DESC"
  end

  visitor_for String do |string|
    "'#{string}'"
  end

  visitor_for Fixnum do |number|
    number.to_s
  end

end

interpreter = ToSql.new

# equal = Condition::Equal.new :field, 'value'
# puts "Equal: #{equal.accept interpreter}"

# not_equal = Condition::Negation.new equal
# puts "Not Equal: #{not_equal.accept interpreter}"

# any = Condition::Any.new equal, not_equal
# puts "Any: #{any.accept interpreter}"

# all = Condition::All.new equal, any
# puts "All: #{all.accept interpreter}"

# not_equal = Condition::Negation.new do |q|
#   q.equal :field, 'value'
# end
# puts "Not Equal: #{not_equal.accept interpreter}"

# asc = Order.new Order::Asc.new(:name)
# puts "Asc: #{asc.accept interpreter}"

# desc = Order.new Order::Desc.new(:name)
# puts "Desc: #{desc.accept interpreter}"

query = Query.new :concept do |q|
  q.where do |c|
    c.or do |x|
      x.equal :z, 'z'
      x.not { |q| q.equal :y, 'y' }
    end
    c.or do |x|
      x.and do |z|
        z.equal :r, 'r'
        z.equal :s, 's'
      end
      x.and do |z|
        z.equal :f, 1
        z.equal :g, 2
      end
    end
    c.equal :a, 'a'
  end
  q.order do |o|
    o.asc :name
    o.desc :count
  end
end
puts "Query: #{query.accept interpreter}"