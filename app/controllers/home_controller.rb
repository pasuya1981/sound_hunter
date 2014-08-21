class HomeController < ApplicationController

layout 'mixes'
  def index

  end

  def welcome
    @tags_ary = EightTracksParser.get_trend_tags
    respond_to do |format|
      format.html
      format.js { puts "Responding to AJAX".red }
    end
  end

  private
end
