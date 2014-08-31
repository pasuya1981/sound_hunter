class ModalController < ApplicationController

  def modal_view_login
  	if request.xhr? 
  	  respond_to do |format|
    	format.js
      end
  	end
  end
end
