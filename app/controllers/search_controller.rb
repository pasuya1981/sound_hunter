class SearchController < ApplicationController
  before_action :init_trend_tag_session
  layout 'search'

  def index
    init_trend_tag_session
    smart_type = keyword_params[:smart_type]
    sort_type = keyword_params[:sort]
    smart_type_in_sym = parse_smart_type smart_type
    sort_type_in_sym = parse_sort_type sort_type
    keyword = keyword_params[:words]
    remember_search_action smart_type, sort_type
    word_in_ary = keyword.strip.split
    mix_set_search_result = search_mix_set(smart_type_in_sym, word_in_ary, sort_type_in_sym)
    init_view_data_with mix_set_search_result
  end

  def hot_tags_search
    smart_type_in_sym = :tags
    sort_type_in_sym = :popular
    keyword = params[:keyword]
    word_in_ary = keyword.split
    mix_set_search_result = search_mix_set(smart_type_in_sym, word_in_ary, sort_type_in_sym)
    init_view_data_with mix_set_search_result
    render 'index' 
  end

  private

  def search_mix_set(smart_type_in_sym, word_in_ary, sort_type_in_sym)
    mix_set_search_result = EightTracksParser.get_mix_set_by_smart_type(smart_type_in_sym, 
                                                                        parames={ user_id: nil, 
                                                                                  keyword: word_in_ary, 
                                                                                  sort: sort_type_in_sym
                                                                                })
    return mix_set_search_result
  end

  def init_view_data_with(mix_set_search_result)
    info = mix_set_search_result.info
    page_info = info[:pagination]
    @mixes = info[:mixes]
    @current_page = page_info[:current_page]
    @per_page = page_info[:per_page]
    @next_page = page_info[:next_page]
    @previous_page = page_info[:previous_page]
    @total_entries = page_info[:total_entries]
  end

  def init_trend_tag_session
    if session[:trend_tags].nil? || session[:trending_tags_created_at] < 1.hours.ago
      session[:trend_tags] = EightTracksParser.get_trend_tags
      session[:trending_tags_created_at] = Time.now
    end
    @tags_ary = session[:trend_tags].shuffle
  end

  def remember_search_action(smart_type, sort_type)
    session[:smart_type_remember] = smart_type
    session[:sort_type_remember]  = sort_type
  end

  def keyword_params
    params.require(:keyword).permit(:words, :smart_type, :sort)
  end

  def parse_sort_type(sort_type)
    sort_type = :popular if sort_type == '熱門'
    sort_type = :recent  if sort_type == '最新'
    sort_type
  end

  def parse_smart_type(smart_type)
    smart_type_in_sym = :artist  if smart_type == '歌手'
    smart_type_in_sym = :keyword if smart_type == '關鍵字'
    smart_type_in_sym = :tags    if smart_type == '標籤'
    smart_type_in_sym = :all unless smart_type_in_sym.present?
    smart_type_in_sym
  end
end
