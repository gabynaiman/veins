class AuthenticationService

  extend Veins::Configurable

  attr_config :implementation

  def self.authenticate(email, password)
    implementation.authenticate email, password
  end

end