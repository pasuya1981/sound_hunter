class HomeController < ApplicationController

layout 'mixes'
  def index

  end

  def welcome
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

  private
end
