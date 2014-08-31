class MixesController < ApplicationController
	before_action :init_trend_tag_session
	layout 'mixes'

	def index
		init_trend_tag_session
		smart_type = keyword_params[:smart_type]
		sort_type = keyword_params[:sort]
		smart_type_in_sym = parse_smart_type smart_type
		sort_type_in_sym = parse_sort_type sort_type
		@keyword = keyword_params[:words]  || params[:keyword][:words]

		if smart_type_in_sym == :artist
			@keyword = @keyword.split.join('-')
		end


		if @keyword.size > 0
		  remember_search_action smart_type, sort_type
		  word_in_ary = @keyword.strip.split
		  mix_set_search_result = search_mix_set(smart_type_in_sym, word_in_ary, sort_type_in_sym)
		  init_view_data_with mix_set_search_result
		end

		if user_logged_in?
		  mix_id = nil
		  session[:collection_hash] = EightTracksParser.get_collection_list_hash(session[:username], mix_id)
		end

		respond_to do |format|
			format.html
			format.js { @keyword }
		end
	end

	def query_next_page
		next_page_path = params[:next_page_path]
		puts "Next page path: #{next_page_path}".blue
		return unless next_page_path.present?
		mix_set_search_result = EightTracksParser.query_next_page next_page_path
		init_view_data_with mix_set_search_result
		respond_to do |format|
			format.html { redirect_to home_path }
			format.js 
		end
	end

	def show
		
		# Render Mix Preview
		@mix_id = params[:mix_id]
		mix = EightTracksParser.get_mix_preview_by(mix_id: @mix_id, user_token: session[:user_token])
		info_hash = mix.info
		@mix_description = info_hash[:description]
		@mix_likes_count = info_hash[:likes_count]
		@mix_duration = info_hash[:duration]
		@mix_tracks_count = info_hash[:tracks_count]
		@mix_nsfw = info_hash[:nsfw]
		@mix_artists = []
		info_hash[:artists].split.each { |artist| @mix_artists << artist } if info_hash[:artists].kind_of?(String)
		info_hash[:artists].each { |k, artist| @mix_artists << artist } if info_hash[:artists].kind_of?(Hash)
		@mix_liked_by_current_user = info_hash[:liked_by_current_user] == 'false' ? false : true 
		@mix_name = info_hash[:name]
		@mix_cover_url = info_hash[:cover_urls][:sq500]
		@mix_cover_sm_url = info_hash[:cover_urls][:sq133]
		@plays_count = info_hash[:plays_count]
		@tag_list_cache = info_hash[:tag_list_cache].gsub(/\//,' ').split(',')

		@mix_genres = []
		if info_hash[:genres].present?
			info_hash[:genres].each { |k, genre| @mix_genres << genre } 
		end

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
			format.html { render 'show' }
			format.js { @mix_id; @mix_cover_sm_url; @mix_name }
		end
	end

	def hot_tags_search
		smart_type_in_sym = :tags
		sort_type_in_sym = :popular
		keyword = params[:keyword]
		word_in_ary = keyword.split
		mix_set_search_result = search_mix_set(smart_type_in_sym, word_in_ary, sort_type_in_sym)
		init_view_data_with mix_set_search_result
		# render :index
		respond_to do |format|
			format.js
			format.html { redirect_to home_path }
		end
	end

	private

	def search_mix_set(smart_type_in_sym, word_in_ary, sort_type_in_sym)
		puts "the sort type is: #{sort_type_in_sym.to_s}".blue
		mix_set_search_result = 
		EightTracksParser.get_mix_set_by_smart_type(smart_type_in_sym, 
																								user_id: nil, 
																								keyword: word_in_ary, 
																								sort: sort_type_in_sym)
		return mix_set_search_result
	end

	def init_view_data_with(mix_set_search_result)
		info = mix_set_search_result.info
		page_info = info[:pagination]
		puts "Page info: #{page_info}".green
		@mixes = info[:mixes]
		@current_page = page_info[:current_page]
		@per_page = page_info[:per_page]
		@next_page = page_info[:next_page]
		@previous_page = page_info[:previous_page]
		@total_entries = page_info[:total_entries]
		@next_page_path = page_info[:next_page_path] if page_info[:next_page_path].present? # /mix_sets/tags:rock+indie?page=2&per_page=12
		session[:mix_first_page_path] = @next_page_path.gsub(/\?page=\d/,'?page=1') if @current_page == '1' && @next_page_path.present?
		@previous_page_path = session[:mix_first_page_path].gsub(/\?page=\d/,"?page=#{@previous_page}") if @previous_page.present?
		#puts "Next page path: #{@next_page_path}. Previous page path: #{@previous_page_path}"
	end

	def init_trend_tag_session
		if session[:trend_tags].nil? || session[:trending_tags_created_at] < 1.hours.ago
			trend_tags = EightTracksParser.get_trend_tags
			session[:trend_tags] = trend_tags
			session[:trending_tags_created_at] = Time.now
		end
		if session[:trend_tags].present?
			@tags_ary = session[:trend_tags].shuffle
		end
	end

	def remember_search_action(smart_type, sort_type)
		session[:smart_type_remember] = smart_type
		session[:sort_type_remember]  = sort_type
	end

	def keyword_params
		params.require(:keyword).permit(:words, :smart_type, :sort)
	end

	def parse_sort_type(sort_type)
		sort_type = :hot if sort_type == '熱門'
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
