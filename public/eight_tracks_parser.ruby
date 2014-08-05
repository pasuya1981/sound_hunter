class EightTracksParser
  require 'open-uri'
  require 'nokogiri'
  require 'net/http'

  # See document online http://8tracks.com/developers/smart_ids
  SMART_TYPE_FOR_EVERYONE       = [:all , :tags       , :artist     , :keyword    , :dj          , :liked      , :similar]
  SMART_TYPE_FOR_LOGGED_IN_USER = [:feed, :social_feed, :listened   , :recommended, :liked]
  SMART_TYPE_RESPOND_TO_USER_ID = [:dj  , :feed       , :social_feed, :liked      , :listen_later, :recommended]
  SORTABLE_SMART_TYPE           = [:all , :artist     , :tags]
  SORTING_PARAMS                = [:hot , :recent     , :popular]
  SMART_TYPE_ALL = SMART_TYPE_FOR_EVERYONE + SMART_TYPE_FOR_LOGGED_IN_USER + SMART_TYPE_RESPOND_TO_USER_ID
  MIX_SET_BASE_URL = "http://8tracks.com/mix_sets/"
  MIX_SET_INCLUDE_QUERY = "include=mixes[user+length]+details" # include Doc: http://8tracks.com/developers/includes
  PLAY_TOKEN_QUERY_BASE_URI = "http://8tracks.com/sets/new.json?"

  
  attr_reader :api_key
  def initialize(api_key)
  	@api_key = api_key
  end

  def get_play_token
    token = nil
    
    raise "Token is nil" unless token
  end


  def get_mix_set_by_smart_type(type=nil, parames={user_id: nil, keyword: [], sort: 'hot'})

    # Error Catch flow
    validate_arguments(type, parames)
    type = type.to_sym unless type.kind_of?(Symbol)

    # Parse params to correct uri
    base_uri = MIX_SET_BASE_URL + type.to_s + ':'
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
    base_uri = ( base_uri + ":" + parames[:sort].to_s ) if parames[:sort]
    base_uri << ".xml?"
    base_uri = base_uri + MIX_SET_INCLUDE_QUERY + "&"
    base_uri << "api_key=#{api_key}&api_version=3"
    raise res_body = open(base_uri).read
     

    # TODO: passing those data to a custom obj...


    # TODO: Return handled data flow
  end

  def get_mixes_tagged_with(*tags) 
    # TODD: write the function
    raise 'No tag provided' unless tags.present?
  end

  def get_trend_tags
    base_uri = "http://8tracks.com/tags.xml?api_key=#{api_key}"
    uri_to_nokogiri_xml(base_uri) do |res_status, res_body, nokogiri_xml|
    	tags = []
      nokogiri_xml.css('tag').each do |tag|
        name = tag.css('name').first.content
        count = tag.css('cool-taggings-count').first.content.gsub(/\+/,'').gsub(/,/,'').to_i # 122,00+ => 12200 (integer)
        tags << { name: name, count: count }
        tags.sort! { |a,b| b[:count] <=> a[:count]  }
      end
      collection = tags.collect {|tag| tag[:name]}
      p collection
    end
  end

  def get_trend_mixes
    base_uri = "http://8tracks.com/mix_sets/all.xml?include=mixes?api_key=#{api_key}"
    uri_to_nokogiri_xml(base_uri) do |res_status, res_body, nokogiri_xml|
      # TODO: Write a class for mix
      raise res_body
      # TODO: Return array of mix class objs
    end
  end

  def loggin(email, password)
    # HTTP post requst flow
    base_uri = URI("https://8tracks.com/sessions.xml") # parse URI for later POST action
    response = Net::HTTP.post_form( base_uri, login: email, 
                                              password: password,
                                              api_version: '3',
                                              api_key: api_key )
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

  private

    def validate_arguments(type, parames)
      raise "Type class can only be string or symbol" unless type.kind_of?(String) || type.kind_of?(Symbol)
      type.to_sym unless type.kind_of?(Symbol)
      type = type.to_sym unless type.kind_of?(Symbol) # turn type to symbole for convenience
      
      raise "Illegle Type: #{type}" unless SMART_TYPE_ALL.include?(type)
      unless parames.nil?
        raise "Unsortable Smart Type" if !SORTABLE_SMART_TYPE.include?(type) && SORTING_PARAMS.include?(parames)
      end
      if SMART_TYPE_RESPOND_TO_USER_ID.include?(type)
        raise "With type: #{type.to_s}, user id param can't be nil" unless parames[:user_id]
        raise "With type: #{type.to_s}, only user id param should be presented" unless parames[:keyword].nil?
      else
        raise "Can't search Type -#{type.to_s}- using user id-#{parames[:user_id]}-" unless parames[:user_id].nil?
      end
      if parames[:keyword]
        raise "Too much paramster: #{parames}" if type != :tags && parames[:keyword].count > 1
      end
      raise "Smart Type parameter must be presented" unless type
      
    end

    def uri_to_nokogiri_xml(base_uri)
    	response = open(base_uri).read
    	xml = Nokogiri::XML(response)
    	status = xml.css('status').first.content
    	yield(status, response, xml) if block_given?
    end

    def safe_url(string)
      pattern_hash = {/_/ => '__', /\s/ => '_',/\./ => '^'}
      safe_str = string.clone # not to alter original string
      pattern_hash.each {|pattern, replacement| safe_str.gsub!(pattern, replacement)}
      safe_str
    end

    def parse_user_info_from(xml, parse_hash={})
      parse_hash[:tracks_user_id]         = xml.css('id').first.content
      parse_hash[:tracks_user_name]       = xml.css('login').first.content
      parse_hash[:tracks_user_email]      = xml.css('email').first.content
      parse_hash[:tracks_user_web_path]   = xml.css('web-path').first.content.to_s.prepend(%q(https://8tracks.com))
      parse_hash[:tracks_user_token]      = xml.css('user-token').first.content
      parse_hash[:tracks_user_avatar_url] = parse_img_url_from( xml.css('sq56').first.content)
      parse_hash.each { |k,v| raise "Empty value" if v.nil? || v.to_s.size < 1  }
      parse_hash      
    end
end

MY_API_KEY = "2b312afc2b28ba56a745c53b49f9288c05f20150"
parser = EightTracksParser.new(MY_API_KEY)
parser.get_mix_set_by_smart_type("tags", keyword: ['michael jackson'], sort: 'hot')

