class SearchController < ApplicationController

  def search
    keyword = params[:keyword][:words].strip.split
    parser = EightTracksDSL::EightTracksParser.new(api_key)
    @mix_set_search_result = parser.get_mix_set_by_smart_type(:tags, parames={user_id: nil, keyword: keyword, sort: 'hot'})

    respond_to do |format|
      format.html { render :welcome }
    end
  end

  def result
  end
end
