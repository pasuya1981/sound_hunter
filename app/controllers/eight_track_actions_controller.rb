class EightTrackActionsController < ApplicationController
  before_action :get_return_to_url

  def new
  	# favor_kind includes 'mix', 'track', 'user'
  end

  def add_collection
    mix_id = params[:mix_id]
    
    behavior = params[:behavior]

    if behavior == 'add'
      collection_id = params[:collection_id]
      # Add collection base URI
      response = 
      EightTracksParser.add_collection(mix_id, collection_id, session[:user_email], session[:user_password]); 
    elsif behavior == 'create'
      collection_name = params[:collection_name]
      response = 
      EightTracksParser.create_collection(mix_id, collection_name, session[:user_email], session[:user_password])
    end       
  end

  def toggle_like
    # Check user token existence.
    @user_token = session[:user_token]
    if @user_token
      puts "Toggle mix like in progress...".red
      # kind = mix or user or track.
      kind = kind_and_id_params[:kind]
      id = kind_and_id_params[:id]
      EightTracksParser.toggle_like_for_kind_and_id(kind, id, @user_token)
    end
    
    respond_to do |format|
      if @user_token
        #format.html { redirect_to show_mix_path(mix_id: id) }
        format.js { @user_token }
      else
        session[:return_to_url] = request.original_url
        #format.html { }
        format.js { puts "AJAX: the user need to login to toggle like action!".blue }
      end
    end
    # redirect_to(controller: :mixes, action: :show, mix_id: id) if kind.to_sym == :mix
  end

  private

  def get_return_to_url
    @return_to_url = request.env["HTTP_REFERER"]
  end

  def kind_and_id_params
  	params.require(:kind_and_id).permit(:kind, :id)
  end
end
