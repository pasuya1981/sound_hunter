class MixesController < ApplicationController
  before_action :init_trend_tag_session
  layout 'mixes'

  def index
    init_trend_tag_session
    smart_type = keyword_params[:smart_type]
    sort_type = keyword_params[:sort]
    smart_type_in_sym = parse_smart_type smart_type
    sort_type_in_sym = parse_sort_type sort_type
    keyword = keyword_params[:words]  || params[:keyword][:words]
    unless keyword.present?
      redirect_to home_path; return; 
    end
    remember_search_action smart_type, sort_type
    word_in_ary = keyword.strip.split
    mix_set_search_result = search_mix_set(smart_type_in_sym, word_in_ary, sort_type_in_sym)
    init_view_data_with mix_set_search_result
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    # Render Mix Preview
    @mix_id = params[:mix_id]
    mix = get_mix_by(@mix_id)
    info_hash = mix.info
    @mix_description = info_hash[:description]
    @mix_likes_count = info_hash[:likes_count]
    @mix_duration = info_hash[:duration]
    @mix_tracks_count = info_hash[:tracks_count]
    @mix_nsfw = info_hash[:nsfw]
    @mix_artists = [];
    info_hash[:artists].split.each { |artist| @mix_artists << artist } if info_hash[:artists].kind_of?(String)
    info_hash[:artists].each { |k, artist| @mix_artists << artist } if info_hash[:artists].kind_of?(Hash)
    @mix_liked_by_current_user = info_hash[:liked_by_current_user] == 'false' ? false : true 
    @mix_name = info_hash[:name]
    @mix_cover_url = info_hash[:cover_urls][:sq500]
    @plays_count = info_hash[:plays_count]
    @tag_list_cache = info_hash[:tag_list_cache].gsub(/\//,' ').split(',')
    @mix_genres = []; info_hash[:genres].each { |k, genre| @mix_genres << genre }
    @first_published_at = info_hash[:first_published_at]

    user_hash = info_hash[:user]
    @user_id = user_hash[:id]
    @user_login = user_hash[:login]
    @user_path = user_hash[:path]
    @user_web_path = user_hash[:web_path]
    @user_avatar = user_hash[:avatar_urls][:sq100]
    @user_followed_by_current_user = user_hash[:followed_by_current_user]
    @user_location = user_hash[:location]
    @member_since = user_hash[:member_since]

    respond_to do |format|
      format.html
      format.js
    end
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

  def query_next_page
    next_page_path = params[:next_page_path]
    return unless next_page_path.present?
    mix_set_search_result = EightTracksParser.query_next_page next_page_path
    init_view_data_with mix_set_search_result
    render :index
  end

  private

  def get_mix_by(mix_id)
    mix = EightTracksParser.get_mix_preview_by(mix_id: mix_id, user_token: session[:user_token])
  end

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
    @next_page_path = page_info[:next_page_path] if page_info[:next_page_path].present? # /mix_sets/tags:rock+indie?page=2&per_page=12
    @previous_page_path = @next_page_path.gsub(/\?page=\d/, "?page=#{@current_page.to_i - 1}") if @current_page.to_i > 1
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
    return smart_type.to_sym if [:artist, :keyword, :tags].include?(smart_type.to_sym)
    smart_type_in_sym = :all unless smart_type_in_sym.present?
    smart_type_in_sym
  end
end
