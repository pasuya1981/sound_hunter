class SearchController < ApplicationController

  def index
    raise request
    keyword = params[:keyword]
    keyword = params[:keyword][:words] unless keyword.kind_of?(String)
    word_in_ary = keyword.strip.split
    mix_set_search_result = EightTracksParser.get_mix_set_by_smart_type(:artist, parames={user_id: nil, keyword: word_in_ary, sort: 'hot'})
    
    # Feed data to view
    info = mix_set_search_result.info
    page_info = info[:pagination]
    @mixes = info[:mixes]
    @current_page = page_info[:current_page]
    @per_page = page_info[:per_page]
    @next_page = page_info[:next_page]
    @previous_page = page_info[:previous_page]
    @total_entries = page_info[:total_entries]
  end

  private

  def keyword_params
    params.require(:keyword).permit(:words)
  end
end
