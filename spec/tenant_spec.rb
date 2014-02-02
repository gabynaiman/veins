require 'minitest_helper'

describe Veins::Tenant do

  before do
    Thread.current[:tenant] = nil
    Veins::Tenant.repository_adapter_class = Veins::Repository::InMemory::Adapter
  end

  it 'Change' do
    Veins::Tenant.current.must_be_nil
    
    Veins::Tenant.use 'user_1'
    
    Veins::Tenant.current.must_be_instance_of Veins::Tenant
    Veins::Tenant.current.name.must_equal 'user_1'
    
    repo_user_1 = Veins::Tenant.current.repository
    repo_user_1.must_be_instance_of Veins::Repository

    Veins::Tenant.use 'user_2'

    Veins::Tenant.current.must_be_instance_of Veins::Tenant
    Veins::Tenant.current.name.must_equal 'user_2'
    
    repo_user_2 = Veins::Tenant.current.repository
    repo_user_2.must_be_instance_of Veins::Repository
    repo_user_2.wont_equal repo_user_1

    Veins::Tenant.use 'user_1'

    Veins::Tenant.current.name.must_equal 'user_1'
    Veins::Tenant.current.repository.must_equal repo_user_1
  end

  it 'Thread safe' do
    Veins::Tenant.current.must_be_nil
    
    Veins::Tenant.use 'user_1'
    
    Veins::Tenant.current.must_be_instance_of Veins::Tenant
    Veins::Tenant.current.name.must_equal 'user_1'
    
    repo_user_1 = Veins::Tenant.current.repository
    repo_user_1.must_be_instance_of Veins::Repository

    t = Thread.new do
      Veins::Tenant.current.must_be_nil
      
      Veins::Tenant.use 'user_2'
      
      Veins::Tenant.current.must_be_instance_of Veins::Tenant
      Veins::Tenant.current.name.must_equal 'user_2'
      
      repo_user_2 = Veins::Tenant.current.repository
      repo_user_2.must_be_instance_of Veins::Repository
      repo_user_2.wont_equal repo_user_1
    end
    t.join

    Veins::Tenant.current.name.must_equal 'user_1'
    Veins::Tenant.current.repository.must_equal repo_user_1
  end

  it 'Separated data' do
    Veins::Tenant.use 'user_1'
    Veins::Tenant.current.repository[:users].save User.new name: 'user_1'
    Veins::Tenant.current.repository[:users].count.must_equal 1

    Veins::Tenant.use 'user_2'
    Veins::Tenant.current.repository[:users].must_be_empty

    Veins::Tenant.use 'user_1'
    Veins::Tenant.current.repository[:users].count.must_equal 1
  end

end