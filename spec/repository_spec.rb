require 'minitest_helper'

describe Veins::Repository do

  let(:adapter) { Veins::Repository::InMemory::Adapter.new }

  let(:repository) { Veins::Repository.new adapter }

  describe 'CRUD' do

    it 'Create' do
      user = User.new name: 'John Doe'
      repository[:users].create user
      user.id.must_equal 1
    end

    it 'Find' do
      user = User.new name: 'John Doe'
      repository[:users].create user
      repository[:users].find(1).must_equal user
    end

    it 'Update' do
      user = User.new name: 'John Doe'
      repository[:users].create user

      repository[:users].find(1).name.must_equal 'John Doe'

      repository[:users].update User.new(id: 1, name: 'Updated name')

      repository[:users].find(1).name.must_equal 'Updated name'
    end

    it 'Save' do
      user = User.new name: 'John Doe'
      repository[:users].save user

      repository[:users].find(1).name.must_equal 'John Doe'

      repository[:users].save User.new(id: 1, name: 'Updated name')

      repository[:users].find(1).name.must_equal 'Updated name'
    end

    it 'Delete' do
      user = User.new name: 'John Doe'
      repository[:users].create user

      repository[:users].count.must_equal 1

      repository[:users].delete 1

      repository[:users].must_be_empty    
    end

  end

  describe 'Collection utils' do

    it 'Empty' do
      repository[:users].must_be_empty
    end

    it 'Count' do
      repository[:users].count.must_equal 0

      user = User.new name: 'John Doe'
      repository[:users].create user

      repository[:users].count.must_equal 1
    end

    it 'All' do
      users = 3.times.map { User.new name: 'John Doe' }

      users.each { |u| repository[:users].create u }

      repository[:users].to_a.must_equal users
    end

  end

  describe 'Queries' do

    before do
      3.times { repository[:users].create User.new name: 'John Doe' }
      4.times { repository[:users].create User.new name: 'Robert Williams' }
    end

    def query_find_by_name(name)
      ->(q) { q.select { |u| u.name == name } }
    end

    it 'Query' do
      repository[:users].count.must_equal 7

      users = repository[:users].query query_find_by_name('John Doe')

      users.count.must_equal 3
    end

    it 'Chained query' do
      query_take_four = ->(q) { q.take 4 }

      repository[:users].query(query_take_four).query(query_find_by_name('Robert Williams')).count.must_equal 1
    end

    it 'Nested queries' do
      last_john_doe = Proc.new do |queriable|
        queriable.query(query_find_by_name('Robert Williams')).query { |q| q.sort_by(&:id).reverse }
      end

      repository[:users].query(last_john_doe).count.must_equal 4
      repository[:users].query(last_john_doe).first.id.must_equal 7
    end

  end

end