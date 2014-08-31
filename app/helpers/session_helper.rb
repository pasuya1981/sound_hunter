module SessionHelper


  def user_session_setup_for(user_model_instance)
  	puts "User model instance inspection: #{user_model_instance.inspect}".blue
    session[:username]   = user_model_instance.username
    session[:user_token] = user_model_instance.tracks_user_token
    session[:avatar_url] = user_model_instance.tracks_user_avatar_url
    session[:tracks_user_id] = user_model_instance.tracks_user_id
  end

  def clear_user_token
  	puts "Clear user session".red
    session[:username]   = nil
    session[:user_token] = nil
    session[:avatar_url] = nil
    session[:tracks_user_id] = nil
  end

  def get_user_token
    session[:user_token]
  end

  def user_avatar_url
    return '' unless user_logged_in?
    User.find_by(tracks_user_token: session[:user_token]).tracks_user_avatar_url
  end

  def user_logged_in?
    session[:user_token].present?
  end

  def current_user?
    token = session[:user_token]
    return false if token.nil?
    User.find_by(tracks_user_token: toke).present?
  end

  def current_user_name
    return '' unless user_logged_in?
    session[:username]
  end
end
