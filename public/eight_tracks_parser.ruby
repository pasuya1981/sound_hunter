class EightTracksParser
  require 'open-uri'
  require 'nokogiri'

  # See document online http://8tracks.com/developers/smart_ids
  SMART_TYPE_FOR_EVERYONE =       ['all' , 'tags'       , 'artist'     , 'keyword'    , 'dj'          , 'liked'      , 'similar']
  SMART_TYPE_FOR_LOGGED_IN_USER = ['feed', 'social_feed', 'listened'   , 'recommended', 'liked']
  SMART_TYPE_RESPOND_TO_USER_ID = ['dj'  , 'feed'       , 'social_feed', 'liked'      , 'listen_later', 'recommended']
  SORTABLE_SMART_TYPE =           ['all' , 'artist'     , 'tags']
  SORTING_PARAMS =                ['hot' , 'recent'     , 'popular']
  SMART_TYPE_ALL = SMART_TYPE_FOR_EVERYONE + SMART_TYPE_FOR_LOGGED_IN_USER
  
  attr_reader :api_key
  def initialize(api_key)
  	@api_key = api_key
  end

  def get_mix_set_by_smart_type(type, *parames)
    raise "Illeagle Type: #{type.to_s}" unless SMART_TYPE_ALL.include?(type)

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

  private
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
      safe_url
    end
end

MY_API_KEY = "2b312afc2b28ba56a745c53b49f9288c05f20150"
parser = EightTracksParser.new(MY_API_KEY)
parser.get_mix_set_by_smart_type 'fake type'

