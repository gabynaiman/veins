require 'minitest_helper'

describe AuthenticateUser do

  before do
    repository[:users].save User.new(name: 'John Doe', email: 'john.doe@mail.com')
  end

  def form(email, password)
    AuthenticateUser::Form.new email: email, password: password
  end

  it 'Successful' do
    user = AuthenticateUser.run! form('john.doe@mail.com', '1234')
    
    user.must_be_instance_of User
    user.id.must_equal 1
    user.name.must_equal 'John Doe'
    user.email.must_equal 'john.doe@mail.com'
  end

  it 'Fail - Invalid password' do
    proc { AuthenticateUser.run! form('john.doe@mail.com', '5555') }.must_raise AuthenticationError
  end

  it 'Fail - Invalid email' do
    proc { AuthenticateUser.run! form('john.doe', '5555') }.must_raise_validation_error email: [:invalid]
  end

  it 'Fail - Empty password' do
    proc { AuthenticateUser.run! form('john.doe@mail.com', '') }.must_raise_validation_error password: [:blank]
  end

end