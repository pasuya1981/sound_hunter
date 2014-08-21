class HomeController < ApplicationController

layout 'mixes'
  def index

  end

  def welcome
    @tags_ary = EightTracksParser.get_trend_tags
    @trending_mixes_ary = EightTracksParser.get_mix_set_by_smart_type(:all).info[:mixes]

    if user_logged_in?
      user = User.find_by(username: session[:username])
      track_id = user.tracks_user_id
      favorite_set = EightTracksParser.get_mix_set_by_smart_type(:liked, user_id: track_id, sort: track_id)
      @favorite_ary = favorite_set.info[:mixes]
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  private
end
