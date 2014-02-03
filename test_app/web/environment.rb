ENV['RACK_ENV'] ||= 'development'

ROOT_PATH = File.expand_path(File.dirname(__FILE__))
Encoding.default_external = Encoding::UTF_8

require 'bundler/setup'
Bundler.require(:default)

require_relative '../app'

Dir[File.join(ROOT_PATH, 'helpers/*.rb')].each { |f| require f }

require 'json'
require 'cuba/render'


class DevelopmentAuthenticationService
  def authenticate(email, password)
    password == 'password'
  end
end
AuthenticationService.implementation = DevelopmentAuthenticationService.new

Veins::Tenant.repository_adapter_class = Veins::Repository::InMemory::Adapter

Cuba.plugin Cuba::Render
Cuba.settings[:render][:template_engine] = :slim
Cuba.settings[:render][:views] = File.join(ROOT_PATH, 'views')

Cuba.use Rack::Session::Cookie, 
         key: 'test_app',
         secret: 'bd2f21a3-2ae2-41e9-8613-20dbaaa1dfc5-9d06bc71-5674-4d20-ac0e-f20c316dee76-037b85d7-9cee-4f46'

Cuba.use Rack::Static,
         urls: %w[/fonts /images /js /css],
         root: File.expand_path('public', File.dirname(__FILE__))

Cuba.plugin CurrentUserHelper

Cuba.define do

  Veins::Tenant.use ENV['RACK_ENV']

  on 'login' do
    on get do
      res.write view('login', form: AuthenticateUser::Form.new)
    end

    on post do
      begin
        user = AuthenticateUser.run! req.params
        set_current_user user.id
        res.redirect '/'
      rescue ValidationError, AuthenticationError => error
        res.write view('login', form: AuthenticateUser::Form.new(email: req.params['email']), error: error)
      end
    end
  end

  on current_user do
  
    on root do
      res.write "Welcome #{current_user}"
    end
    
  end

  on default do
    res.redirect '/login'
  end

end
