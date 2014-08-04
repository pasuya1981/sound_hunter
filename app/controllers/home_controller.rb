class HomeController < ApplicationController
  def index
    
  end

  def welcome
    @trending_tag_hash = currently_trending_tags
    raise @trending_tag_hash
  end
end
