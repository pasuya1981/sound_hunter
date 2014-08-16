class PlayerController < ApplicationController

  def play
  	mix_id = play_params[:mix_id]
  	setup_session_play_token unless session[:play_token]
  	mix_play_info_hash = EightTracksParser.get_mix_play_info(session[:play_token], mix_id)

    audio_stream_url = mix_play_info_hash[:set][:track][:track_file_stream_url]
    track_name = mix_play_info_hash[:set][:track][:name]
    performer = mix_play_info_hash[:set][:track][:performer]
    year = mix_play_info_hash[:set][:track][:year]
    buy_link = mix_play_info_hash[:set][:track][:buy_link]
    buy_icon = mix_play_info_hash[:set][:track][:buy_icon]
    buy_text = mix_play_info_hash[:set][:track][:buy_text]
    release_name = mix_play_info_hash[:set][:track][:release_name]

    @track_info = { audio_stream_url: audio_stream_url, 
                    track_name: track_name,
                    performer: performer,
                    year: year,
                    buy_link: buy_link,
                    buy_icon: buy_icon,
                    buy_text: buy_text,
                    release_name: release_name
                  }

    @mix_id = mix_id
  	respond_to do |format|
  	  format.js { @track_info }
      format.html { redirect_to home_path }
  	end
  end

  def pause
    
  end

  def resume
    
  end


  private 

  def play_params
  	params.require(:play).permit(:mix_id)
  end

  def setup_session_play_token; 
  	session[:play_token] = EightTracksParser.get_play_token
  end
end
