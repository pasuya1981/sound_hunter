class HomeController < ApplicationController
  def index
    
  end

  def welcome
  	init_trend_tag_session
  end

  private

    def init_trend_tag_session
      reset_tags_session if session[:trend_tags].nil? || session[:trending_tags_created_at] < Time.now.weeks_ago(1)
    end

    def reset_tags_session
      session[:trend_tags] = get_currently_trending_tags
      session[:trending_tags_created_at] = Time.now
    end
end
