require 'minitest_helper'

describe Veins::Persistence::Adapters::SQL do

  DB = Sequel.sqlite

  before do
    DB.drop_table? :countries, :cities

    DB.create_table :countries do
      primary_key :id
      String      :name
    end

    DB.create_table :cities do
      primary_key :id
      String      :name
      Integer     :country_id
    end    
  end

  let(:adapter_config) { [Veins::Persistence::Adapters::SQL, DB] }

  let :mapper do
    config = adapter_config

    mapper = Veins::Persistence::Mapper.new do
      collection Country, name: :countries do
        attribute :id
        attribute :name
        list :cities, City
      end

      collection City, name: :cities do
        attribute :id
        attribute :name
        reference :country, Country
      end

      adapter :default, *config
    end
  end

  let(:adapter) { mapper.adapters[:default] }

  # def find(model_class, id)
  #   adapter.db[mapper.collections[model_class].name].where(id: id).first
  # end

  def insert(model)
    collection = mapper.collections[model.class]
    DB[collection.name].insert(collection.serialize(model))
  end

  it 'Find' do
    countries = 3.times.map do |i|
      Country.new name: "Country #{i}"
    end
    countries.each { |c| adapter.create Country, c }

    adapter.find(Country, countries[2].id).name.must_equal 'Country 2'
    error = proc { adapter.find(Country, 100) }.must_raise Veins::Persistence::NotFoundError
    error.model_class.must_equal Country
    error.id.must_equal 100
    error.message.must_equal 'Country 100 not found'
  end
    
  it 'All' do
    adapter.create Country, Country.new(name: 'Argentina')
    adapter.create Country, Country.new(name: 'Uruguay')

    adapter.all(Country).map{|c| c[:name]}.must_equal %w(Argentina Uruguay)
  end

  it 'Create' do
    skip
    country = Country.new name: 'Argentina'
    adapter.create Country, country

    country.id.wont_be_nil
    find(Country, country.id)[:name].must_equal 'Argentina'
  end
  
  it 'Update' do
    skip
    country = Country.new name: 'Argentina'
    
    adapter.create Country, country
    find(Country, country.id)[:name].must_equal 'Argentina'

    country.name = 'Uruguay'
    adapter.update Country, country
    find(Country, country.id)[:name].must_equal 'Uruguay' 
  end
  
  it 'Delete' do
    skip
    country = Country.new name: 'Argentina'
    
    adapter.create Country, country
    find(Country, country.id)[:name].must_equal 'Argentina'

    adapter.delete Country, country.id
    find(Country, country.id).must_be_nil
  end

  it 'Query' do
    skip
    1.upto(10) do |i|
      adapter.create Country, Country.new(name: "Country #{i}")
    end

    result = adapter.query(Country).where(:id, :<, 5).order(:name, :desc)
    
    result.count.must_equal 4
    result.map(&:name).must_equal ['Country 4', 'Country 3', 'Country 2', 'Country 1']
  end

  it 'Reference association' do
    skip
    country = Country.new name: 'Argentina'
    adapter.create Country, country

    city = City.new name: 'Bs.As.', country: country
    adapter.create City, city

    adapter.collections[City][city.id].must_equal id: city.id, name: city.name, country_id: country.id
    reference = adapter.find(City, city.id).country

    reference.id.must_equal country.id
    reference.loaded?.must_equal false
    reference.name.must_equal 'Argentina'
    reference.loaded?.must_equal true
    reference.is_a?(Country).must_equal true

    country.name = 'Uruguay'
    adapter.update Country, country

    reference.name.wont_equal country.name
    reference.reload.name.must_equal country.name
  end

  it 'List association' do
    skip
    country = Country.new name: 'Argentina'
    adapter.create Country, country

    country.cities.must_equal []

    adapter.create City, City.new(name: 'Bs.As.', country: country)
    adapter.create City, City.new(name: 'Rosario', country: country)

    country = adapter.find Country, country.id

    country.cities.loaded?.must_equal false
    country.cities.map(&:name).must_equal ['Bs.As.', 'Rosario']
    country.cities.loaded?.must_equal true

    adapter.create City, City.new(name: 'Cordoba', country: country)

    country.cities.map(&:name).wont_equal ['Bs.As.', 'Rosario', 'Cordoba']
    country.cities.reload.map(&:name).must_equal ['Bs.As.', 'Rosario', 'Cordoba']
  end

end