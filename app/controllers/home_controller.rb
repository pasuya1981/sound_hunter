class HomeController < ApplicationController

layout 'mixes'
  def index

  end

  def welcome
    init_view_data
  end

  def welcome_ajax
    if request.xhr?
      puts "It is ajax request".red
      init_view_data
      respond_to do |format|
        format.js {}
      end
    else 
      # raise "Not a AJAX request!"
    end
  end

  private

  def init_view_data
    @trending_mixes = EightTracksParser.get_mix_set_by_smart_type(:all).info[:mixes]
    if user_logged_in?
      tracks_user_id = session[:tracks_user_id]
      favorite_set = EightTracksParser.get_mix_set_by_smart_type(:liked, user_id: tracks_user_id, sort: :popular)
      @favorite_mixes = favorite_set.info[:mixes]
      recommend_set = EightTracksParser.get_mix_set_by_smart_type(:recommended, user_id: tracks_user_id, sort: :popular)
      @recommended_mixes = recommend_set.info[:mixes]
    end
    @tags_ary = EightTracksParser.get_trend_tags
  end
end
