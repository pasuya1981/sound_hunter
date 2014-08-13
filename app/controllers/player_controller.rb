class PlayerController < ApplicationController

  def play
  	mix_id = play_params[:mix_id]
  	setup_session_play_token unless session[:play_token]
  	EightTracksParser.get_mix_play_info(session[:play_token], mix_id)
  end


  private 

  def play_params
  	params.require(:play).permit(:mix_id)
  end

  def setup_session_play_token; 
  	session[:play_token] = EightTracksParser.get_play_token
  end
end
