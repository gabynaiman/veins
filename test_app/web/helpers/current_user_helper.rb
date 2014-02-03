module CurrentUserHelper
  def current_user
    req.session[:current_user]
  end

  def set_current_user(user)
    req.session[:current_user] = user
  end
end