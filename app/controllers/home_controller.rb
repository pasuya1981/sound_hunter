class HomeController < ApplicationController

layout 'mixes'
  def index

  end

  def welcome
    @tags_ary = EightTracksParser.get_trend_tags
    @trending_mixes_ary = EightTracksParser.get_mix_set_by_smart_type(:all).info[:mixes]
    p @glide_page_index_with_mixes
    respond_to do |format|
      format.html
      format.js { puts "Responding to AJAX".red }
    end
  end

  private
end
