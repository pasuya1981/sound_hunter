module EightTracksParser  
  extend ActiveSupport::Concern
  require 'open-uri'
  require 'nokogiri'
  require 'net/http'
  #require 'mix_module'

  include MixModule

  # See document online http://8tracks.com/developers/smart_ids
  SMART_TYPE_FOR_EVERYONE       = [:all , :tags       , :artist     , :keyword    , :dj          , :liked      , :similar]
  SMART_TYPE_FOR_LOGGED_IN_USER = [:feed, :social_feed, :listened   , :recommended, :liked]
  SMART_TYPE_RESPOND_TO_USER_ID = [:dj  , :feed       , :social_feed, :liked      , :listen_later, :recommended]
  SORTABLE_SMART_TYPE           = [:all , :artist     , :tags]
  SORTING_PARAMS                = [:hot , :recent     , :popular]
  SMART_TYPE_ALL = SMART_TYPE_FOR_EVERYONE + SMART_TYPE_FOR_LOGGED_IN_USER + SMART_TYPE_RESPOND_TO_USER_ID

  def node_name_to_sym(node_name)
    node_name.gsub(/-/, '_').to_sym
  end

  def toggle_like_for_kind_and_id(kind, id, user_token) # kind = "mix" or "track", see DOC "http://8tracks.com/developers/api_v3#like"
    kind = kind == 'mix' ? 'mixes' : 'tracks'
    base_uri = "http://8tracks.com/#{kind}/#{id}/toggle_like.xml?api_version=3&api_key=#{api_key}&user_token=#{user_token}"
    liked_by_current_user = nil
    uri_to_nokogiri_xml base_uri do |status, nokogiri_xml|
      raise "status error: #{status}" unless status =~ /200 ok/i
      liked_by_current_user = nokogiri_xml.css('liked-by-current-user').first.content
    end
    puts "Finish toggle like and result is #{liked_by_current_user}".red
    return liked_by_current_user
  end

  def toggle_follow_user(id)
    # TODO: write the function
  end

  def get_mix_preview_by(params={mix_id: nil, user_token: nil})
    mix_id = params[:mix_id]
    user_token = params[:user_token]
    raise "mix id is not form of number" unless mix_id.kind_of?(Fixnum) || mix_id.to_i.kind_of?(Fixnum)
    base_uri = "http://8tracks.com/mixes/#{mix_id}.xml?api_version=3&api_key=#{api_key}"
    base_uri << "&user_token=#{user_token}" if user_token
    noko_xml = nil
    uri_to_nokogiri_xml(base_uri) do |status, nokogiri_xml|
      validate_status_and_nokogiri_xml(status, nokogiri_xml)
      noko_xml = nokogiri_xml
    end
    mix_info_hash = cursive_parse_xml_to_hash(noko_xml)
    raise "Parsing XML seems got error" unless mix_info_hash[:response][:mix]
    mix_info_hash = mix_info_hash[:response][:mix]
    mix_obj = Mix.new(mix_info_hash)
  end

  def cursive_parse_xml_to_hash(nokogiri_xml)
    info = {}
    nokogiri_xml.xpath("./*").each do |node|
      node_name_in_sym = node_name_to_sym(node.name)
      if node.xpath("./*").count > 0
        info[node_name_in_sym] = cursive_parse_xml_to_hash(node)
      elsif node.xpath("./*").count == 0
        info[node_name_in_sym] = node.content
      end
    end
    info
  end

  def log_user_to_8tracks(email, password)
    uri = URI.parse("http://8tracks.com/sessions.xml")
    response = Net::HTTP.post_form(uri, api_version: "3", 
                                           api_key: api_key, 
                                             login: email, 
                                          password: password)
    nokogiri_xml = Nokogiri::XML(response.body)
    user_info = {}
    user_info[:tracks_user_name] = nokogiri_xml.css('login').first.content
    user_info[:tracks_user_id] = nokogiri_xml.css('id').first.content
    user_info[:tracks_user_email] = nokogiri_xml.css('email').first.content
    user_info[:tracks_user_token] = nokogiri_xml.css('user-token').first.content
    user_info[:tracks_user_web_path] = nokogiri_xml.css('web-path').first.content
    user_info[:tracks_user_avatar_url] = nokogiri_xml.css('avatar-urls max200').first.content
    return user_info
  end

  def get_play_token
    base_uri = "http://8tracks.com/sets/new.xml?api_version=3&api_key=#{api_key}"
    uri_to_nokogiri_xml(base_uri) do |status, nokogiri_xml|
      return nil unless status =~ /200 ok/i
      return nokogiri_xml.css('play-token').first.content
    end
  end
    
  def get_mix_play_info(play_token, mix_id)
    base_uri = "http://8tracks.com/sets/#{play_token}/play.xml?mix_id=#{mix_id}&api_version=3&api_key=#{api_key}"
    uri_to_nokogiri_xml(base_uri) do |status, nokogiri_xml|
      mix_play_info_hash = cursive_parse_xml_to_hash(nokogiri_xml)
      mix_play_info_hash = mix_play_info_hash[:response] if mix_play_info_hash[:response]
    end
  end

  def query_next_page(query_str) # "/mix_sets/tags:rock+indie?page=2&per_page=12"
    query_head = query_str.gsub(/\?.*/, '')
    query_rear = query_str.gsub(/.*\?/,'')
    query_str  = query_head << ".xml" << "?" << get_include_query_str << "&" << query_rear
    base_uri   = "http://8tracks.com" << query_str << "&api_version=3&api_key=#{api_key}"
    uri_to_nokogiri_xml(base_uri) do |status, nokogiri_xml|
      validate_status_and_nokogiri_xml(status, nokogiri_xml)
      mix_set = create_mix_set_model_from nokogiri_xml
      return mix_set
    end
  end

  def get_mix_set_by_smart_type(type=nil, parames={user_id: nil, keyword: [], sort: :popular})
    # Error Catch flow
    base_uri = "http://8tracks.com/mix_sets/"
    validate_arguments(type, parames)
    type = type.to_sym unless type.kind_of?(Symbol)
    # Parse params to correct uri
    base_uri = base_uri + type.to_s + ':'
    if parames[:user_id]
      base_uri += "#{parames[:user_id]}"
    elsif parames[:keyword]
      if parames[:keyword].count > 0
        counts = parames[:keyword].count
        key_str = ''
        counts.times do |n|
          key = parames[:keyword][n-1]
          key_str += key
          key_str += '+' if n < counts-1
        end
        url_safe_key_str = safe_url key_str
        base_uri << url_safe_key_str
      end
    end
    include_query = get_include_query_str  # include Doc: http://8tracks.com/developers/includes
    base_uri = base_uri + ":" + parames[:sort].to_s
    base_uri << ".xml?"
    base_uri = base_uri + include_query
    base_uri << "&api_key=#{api_key}&api_version=3"

    # Connect to 8tracks server
    uri_to_nokogiri_xml(base_uri) do |status, nokogiri_xml|
      validate_status_and_nokogiri_xml(status, nokogiri_xml)
      mix_set = create_mix_set_model_from(nokogiri_xml)
      return mix_set
    end
  end

  def get_trend_tags
    base_url = "http://8tracks.com/tags.xml?api_key=#{api_key}"
    response_body = open(base_url).read
    xml = Nokogiri::XML(response_body)
    res_status = xml.css('status').first.content  

    if res_status =~ /200 OK/i
      tags_ary = []
      xml.css('tag').count.times do |n|
        children = xml.css('tag')[n-1].children
        tag_name = children.css('name').first.content
        tagging_count = children.css('cool-taggings-count').first.content
        tags_ary << { tag_name: tag_name, taggin_count: tagging_count }
      end
      tags_ary
    else
      raise "Server bad response: #{res_status}"
    end 
  end

  def signup_user_to_8tracks(user_name, email, password)
    base_uri = URI("https://8tracks.com/users.xml")
    response = Net::HTTP.post_form( base_uri, api_version: '3',
                                              api_key: api_key,
                                              "user[login]" => user_name,
                                               "user[email]" => email,
                                               "user[password]" => password,
                                               "user[agree_to_terms]" => '1')
    xml = Nokogiri::XML(response.body)
    response_status = xml.css('status').first.content
    if response_status.to_s =~ /201 created/i || response_status.to_s =~ /200 ok/i
      user_info = parse_user_info_from(xml)
    elsif response_status =~ /422 Unprocessable Entity/i
      error_msg = xml.css('validation-errors').first.content
      user_info = { error: error_msg }
    end
  end

  def loggin(email, password)
    # HTTP post requst flow
    base_uri = URI("https://8tracks.com/sessions.xml") # parse URI for later POST action
    response = Net::HTTP.post_form( base_uri, login: email, 
                                              password: password,
                                              api_version: '3',
                                              api_key: api_key )
    raise response.body
    xml = Nokogiri::XML(response.body)
    response_status = xml.css('status').first.content  
    if response_status =~ /200 ok/i
      user_info = parse_user_info_from(xml)
    elsif response_status =~ /422 Unprocessable Entity/i
      return nil
    else
      raise "Unkown Error...#{response_status}"
    end
  end

  def create_mix_set_model_from(nokogiri_xml)
    mix_set    = MixSet.new; 
    info       = {} 
    mixes      = [] 
    pagination = {} 
    tags_list  = []
    nokogiri_xml.css('mix-set/*').each do |node|
      node_name = node.name
      name_in_symbol = node_name.gsub(/-/, '_').to_sym
      if node_name == 'mixes'
        node.css("/mix").each do |mix_node|
          mixes << create_mix_from(mix_node)
        end
      elsif node_name == 'tags-list'
        node.css("/*").each do |tag_elem|
          tags_list << tag_elem.content
        end
      elsif node_name == 'pagination'
        node.css('/*').each do |page_elem|
          pagination[page_elem.name.gsub(/-/, '_').to_sym] = page_elem.content
        end
      else
        info[name_in_symbol] = node.content
      end
    end
    info[:mixes] = mixes
    info[:tags_list] = tags_list
    info[:pagination] = pagination
    mix_set.info = info
    return mix_set
  end

  def create_mix_from(mix_xml)
    mix_obj = Mix.new
    preview = {} # feed info to MixPreview obj
    mix_xml.css("/*").each do |mix_preview_xml|
      nod_name = mix_preview_xml.name
      name_in_symbol = nod_name.gsub(/-/, '_').to_sym

      if nod_name == 'user'
        preview[:user] = create_user_preview_from(mix_preview_xml)
      elsif mix_preview_xml.name == 'cover-urls'
        preview[name_in_symbol] = mix_preview_xml.css("sq250").first.content # .gsub(/\?.*/, '')
      else
        preview[name_in_symbol] = mix_preview_xml.content
      end
    end
    mix_obj.info[:preview] = preview
    return mix_obj
  end

  def create_user_preview_from(mix_preview_xml_scoped_to_user)
    user = TracksUser.new
    preview = {}
    mix_preview_xml_scoped_to_user.css("/*").each do |user_preview_xml|
      nod_name = user_preview_xml.name
      name_in_symbol = user_preview_xml.name.gsub(/-/, '_').to_sym

      if nod_name == "avatar-urls"
        preview[name_in_symbol] = user_preview_xml.css('/*').first.content.gsub(/\?.*/, '')
      else
        preview[name_in_symbol] = user_preview_xml.content
      end
    end
    user.info[:preview] = preview
    return user
  end

  private

  def validate_status_and_nokogiri_xml(status, nokogiri_xml)
    raise "Nokogiri XML can't be nil" if nokogiri_xml.nil?
    raise "Response is not ok -- #{status}\n#{nokogiri_xml.to_xml}" unless status =~ /200 ok/i
  end

  def get_include_query_str
    "include=mixes_details+details+pagination+relative_name"
  end

  def api_key
    "2b312afc2b28ba56a745c53b49f9288c05f20150"
  end
  
  def utf8_encoder(string)
    string = string.encode(Encoding::ISO_8859_1)
  end

  def validate_arguments(type, parames)
      raise "Type class can only be string or symbol" unless type.kind_of?(String) || type.kind_of?(Symbol)
      type.to_sym unless type.kind_of?(Symbol)
      type = type.to_sym unless type.kind_of?(Symbol) # turn type to symbole for convenience
      
      raise "Illegle Type: #{type}" unless SMART_TYPE_ALL.include?(type)
      unless parames.nil?
        raise "Unsortable Smart Type" if !SORTABLE_SMART_TYPE.include?(type) && SORTING_PARAMS.include?(parames)
      end
      if SMART_TYPE_RESPOND_TO_USER_ID.include?(type)
        raise "With type: #{type.to_s}, user id param can't be nil" unless parames[:user_id].to_s.size > 0
        raise "With type: #{type.to_s}, only user id param should be presented" unless parames[:keyword].nil?
      else
        raise "Can't search Type -#{type.to_s}- using user id-#{parames[:user_id]}-" unless parames[:user_id].nil?
      end
      # -- This check seems to cause troble. --
      #if parames[:keyword]
      #  raise "Too much paramster: #{parames}" if type != :tags && parames[:keyword].count > 1
      #end
      raise "Smart Type parameter must be presented" unless type 
  end

  def uri_to_nokogiri_xml(base_uri)
    #puts base_uri.red
    unless base_uri =~ /&page=\d/i # prevent repeated escape
#      puts "escaping base uri...".blue
      base_uri = URI::escape base_uri
    end
    response = open(base_uri).read
    xml = Nokogiri::XML(response)
    status = xml.css('status').first.content 
    yield(status, xml) if block_given?  
  end

  def safe_url(string)
      unless string =~ /\?page=\d/i
        pattern_hash = {/_/ => '__', /\s/ => '_', /\./ => '^'}
        safe_str = string.clone # not to alter original string
        pattern_hash.each {|pattern, replacement| safe_str.gsub!(pattern, replacement)}
        safe_str
      end
  end

  def parse_user_info_from(xml, parse_hash={})
    parse_hash[:tracks_user_id]         = xml.css('id').first.content
    parse_hash[:tracks_user_name]       = xml.css('login').first.content
    parse_hash[:tracks_user_email]      = xml.css('email').first.content
    parse_hash[:tracks_user_web_path]   = xml.css('web-path').first.content.to_s.prepend(%q(https://8tracks.com))
    parse_hash[:tracks_user_token]      = xml.css('user-token').first.content
    parse_hash[:tracks_user_avatar_url] = parse_img_url_from( xml.css('sq56').first.content)
    parse_hash.each { |k,v| raise "Empty value" if v.to_s.size < 1  }
    parse_hash       
  end

  def parse_img_url_from(base_url)
    base_url.gsub(/\?.*\z/, '?') # http://path/to/imamge_file.jpg?params => http://path/to/imamge_file.jpg?
  end
end

