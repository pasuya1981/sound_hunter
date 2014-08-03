module ApplicationHelper

# CSS style for bootstrap 3
# <div class="alert alert-success" role="alert">...</div>
# <div class="alert alert-info" role="alert">...</div>
# <div class="alert alert-warning" role="alert">...</div>
# <div class="alert alert-danger" role="alert">...</div>

  def bootstrap_class_for flash_type
  	{success: 'alert-success', 
     error: 'alert-error', 
     alert: 'alert-block', 
     notice: 'alert-info'}[flash_type] || 'alert-info'
  end

  def user_logged_in?
    session[:user_token].present?
  end

  def clear_user_token
    session[:user_token] = nil
  end

  def dynamic_action_name
    action_name = controller.action_name
    return 'create' if action_name =~ /new/i
    return 'create_8_tracks_ac' if action_name =~ /signup/i
  end
end
