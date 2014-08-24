class ModalController < ApplicationController

  def modal_view_login
  	if request.xhr? 
  	  respond_to do |format|
    	format.html
    	format.js
      end
  	end
  end
end
