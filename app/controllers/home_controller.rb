class HomeController < ApplicationController

  layout 'mixes'

  def index
    
  end

  def welcome
    respond_to do |format|
      format.js { }
    end
  end

  private
end
