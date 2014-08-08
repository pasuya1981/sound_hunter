class HomeController < ApplicationController

  def index
    
  end

  def welcome
  	init_trend_tag_session
    @tags_ary = session[:trend_tags].shuffle
  end

  private

  def init_trend_tag_session
    reset_tags_session if session[:trend_tags].nil? || session[:trending_tags_created_at] < 1.minutes.ago
  end

  def reset_tags_session
    session[:trend_tags] = EightTracksParser.new(api_key).get_trend_tags
    session[:trending_tags_created_at] = Time.now
  end

  def api_key
  "2b312afc2b28ba56a745c53b49f9288c05f20150"
  end
end
