class FavoriteController < ApplicationController
  before_action :get_return_to_url, :check_user_token

  def new
  	# favor_kind includes 'mix', 'track', 'user'
  end

  def toggle_like
    puts "toggle like".red
    # kind = mix or user or track.
    kind = kind_and_id_params[:kind]
    id = kind_and_id_params[:id]
    EightTracksParser.toggle_like_for_kind_and_id(kind, id, session[:user_token])
    respond_to do |format|
      format.js { puts "resond to ajax".red }
      format.html { redirect_to show_mix_path(mix_id: id) }
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

  def check_user_token
    if session[:user_token].nil?
      flash[:notice] = "請先登入"
      session[:return_to_url] = request.original_url
      redirect_to login_path
    end
  end
end
