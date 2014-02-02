class AuthenticateUser < Veins::UseCase

  class Form < Veins::Form

    attr_reader :email
    attr_reader :password

    def initialize(attributes)
      @email = attributes[:email]
      @password = attributes[:password]
    end

    private

    def validate(errors)
      errors[:email] << :cant_be_blank if email.empty?
      errors[:email] << :invalid unless email.match /.+@.+\..+/
      errors[:password] << :blank if password.empty?
    end

  end

  private

  def run
    raise AuthenticationError unless AuthenticationService.authenticate(form.email, form.password)
    find_user 
  end

  def find_user
    repository[:users].query { |q| q.select { |u| u.email == form.email } }.first
  end

end