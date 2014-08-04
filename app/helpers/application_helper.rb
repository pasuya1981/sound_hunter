module ApplicationHelper

# CSS style for bootstrap 3
# <div class="alert alert-success" role="alert">...</div>
# <div class="alert alert-info" role="alert">...</div>
# <div class="alert alert-warning" role="alert">...</div>
# <div class="alert alert-danger" role="alert">...</div>

  def bootstrap_class_for flash_type
  	style = { success: 'alert-success', 
              info:    'alert-info', 
              warning: 'alert-warning', 
              danger:  'alert-danger' }[flash_type.to_sym] || 'alert-info'
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

  def user_session_setup_for(user_model_instance)
    session[:username]   = user_model_instance.username
    session[:user_token] = user_model_instance.tracks_user_token
    session[:avatar_url] = user_model_instance.tracks_user_avatar_url
  end
end
