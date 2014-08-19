class PlayerController < ApplicationController

  def play
  	@mix_id = play_params[:mix_id]
  	@play_token = session[:play_token] ||= EightTracksParser.get_play_token
  	mix_play_info_hash = EightTracksParser.get_mix_play_info(session[:play_token], @mix_id)

    is_at_beginning = mix_play_info_hash[:set][:at_beginning]
    is_at_end = mix_play_info_hash[:set][:at_end] # true if you are past the final track.
    is_at_last_track = mix_play_info_hash[:set][:at_last_track]
    skip_allowed = mix_play_info_hash[:set][:skip_allowed]
    p mix_play_info_hash
    audio_stream_url = mix_play_info_hash[:set][:track][:track_file_stream_url]
    track_name = mix_play_info_hash[:set][:track][:name]
    performer = mix_play_info_hash[:set][:track][:performer]
    year = mix_play_info_hash[:set][:track][:year]
    buy_link = mix_play_info_hash[:set][:track][:buy_link]
    buy_icon = mix_play_info_hash[:set][:track][:buy_icon]
    buy_text = mix_play_info_hash[:set][:track][:buy_text]
    release_name = mix_play_info_hash[:set][:track][:release_name]

    @track_info = { is_at_beginning: is_at_beginning,
                    is_at_end: is_at_end,
                    is_at_last_track: is_at_last_track,
                    skip_allowed: skip_allowed,
                    audio_stream_url: audio_stream_url, 
                    track_name: track_name,
                    performer: performer,
                    year: year,
                    buy_link: buy_link,
                    buy_icon: buy_icon,
                    buy_text: buy_text,
                    release_name: release_name,
                    mix_id: @mix_id
                  }
  	respond_to do |format|
  	  format.js { @mix_id; @play_token; @track_info }
      format.html { redirect_to home_path }
  	end
  end
  
  private 

  def play_params
  	params.require(:play).permit(:mix_id)
  end
end
