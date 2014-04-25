require 'minitest_helper'

describe Veins::Persistence::Mapper do
 
  describe 'Collections' do

    it 'Attribute' do
      mapper = Veins::Persistence::Mapper.new do
        collection Country do
          attribute :id
        end
      end

      mapper.collections[Country].attributes.map(&:name).must_equal [:id]
    end

    it 'Reference' do
      mapper = Veins::Persistence::Mapper.new do
        collection City do
          reference :country, Country
        end
      end

      mapper.collections[City].references.first.tap do |ref|
        ref.name.must_equal :country
        ref.model_class.must_equal Country
      end
    end

    it 'List' do
      mapper = Veins::Persistence::Mapper.new do
        collection Country do
          list :cities, City
        end
      end

      mapper.collections[Country].lists.first.tap do |list|
        list.name.must_equal :cities
        list.model_class.must_equal City
      end
    end

  end

  describe 'Adapters' do

    it 'Default' do
      mapper = Veins::Persistence::Mapper.new do
        collection Country
      end

      mapper.collections[Country].adapter_name.must_equal :default
    end

    it 'Specific' do
      mapper = Veins::Persistence::Mapper.new do
        collection Country do
          adapter :custom_adapter
        end
      end

      mapper.collections[Country].adapter_name.must_equal :custom_adapter
    end

    it 'Configuration' do
      mapper = Veins::Persistence::Mapper.new do
        adapter :default, Veins::Persistence::Adapters::InMemory
        adapter :custom, CustomAdapter
      end

      mapper.adapters.count.must_equal 2
      mapper.adapters[:default].must_be_instance_of Veins::Persistence::Adapters::InMemory
      mapper.adapters[:custom].must_be_instance_of CustomAdapter
    end

    it 'For collection' do
      mapper = Veins::Persistence::Mapper.new do
        collection Country
        collection City do
          adapter :custom
        end

        adapter :default, Veins::Persistence::Adapters::InMemory
        adapter :custom, CustomAdapter
      end

      mapper.adapter_for(Country).must_be_instance_of Veins::Persistence::Adapters::InMemory
      mapper.adapter_for(City).must_be_instance_of CustomAdapter
    end

  end

end