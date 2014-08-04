
# Let views-module-methods visible to controller side ( default: invisible )
include ApplicationHelper
include TracksDsl # concern module

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
