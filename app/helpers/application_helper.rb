module ApplicationHelper

# CSS style for bootstrap 3
# <div class="alert alert-success" role="alert">...</div>
# <div class="alert alert-info" role="alert">...</div>
# <div class="alert alert-warning" role="alert">...</div>
# <div class="alert alert-danger" role="alert">...</div>

  def bootstrap_class_for flash_type
  	{ success: 'alert-success', 
      error: 'alert-error', 
      alert: 'alert-block', 
      notice: 'alert-info' }[flash_type] || 'alert-info'
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

  def clear_user_token
    session[:user_token] = nil
    session[:avatar_url] = nil
  end

  def dynamic_action_name
    action_name = controller.action_name
    return 'create' if action_name =~ /new/i
    return 'create_eight_tracks_account' if action_name =~ /signup/i
  end

  def user_session_setup(username, user_token, user_avatar_url)
    session[:username] = username
    session[:user_token] = user_token
    session[:avatar_url] = user_avatar_url 
  end
end
