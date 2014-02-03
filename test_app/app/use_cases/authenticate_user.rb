class AuthenticateUser < Veins::UseCase

  class Form < Veins::Form

    attr_reader :email
    attr_reader :password

    private

    def validate(errors)
      if email.nil? || email.empty?
        errors[:email] << :blank 
      else
        errors[:email] << :invalid unless email.match /.+@.+\..+/
      end
      errors[:password] << :blank if password.nil? || password.empty?
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