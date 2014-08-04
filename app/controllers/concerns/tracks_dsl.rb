module TracksDsl
  extend ActiveSupport::Concern
  require 'nokogiri'
  require 'open-uri'

# SoundCloud credientials
#   CLIENT_ID = '90dc4f7f5b8f96149559894d9b7c2068'
#   CLIENT_SECRET =  '54dd0ecd6790e0bc3f5a6283b030111d'

# Example to extend the model(?) class
#  included do
#    has_many :taggings, as: :taggable
#    has_many :tags, through: :taggings    
#    class_attribute :tag_limit
#  end

  EIGHT_TRACK_API_KEY = '2b312afc2b28ba56a745c53b49f9288c05f20150'

  def log_user_to_8tracks(email, password)
    # HTTP post requst flow
    base_uri = URI("https://8tracks.com/sessions.xml")
    response = Net::HTTP.post_form( base_uri, login: email, 
                                              password: password,
                                              api_version: '3',
                                              api_key: EIGHT_TRACK_API_KEY )
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

  def signup_user_to_8tracks(user_name, email, password)
    base_uri = URI("https://8tracks.com/users.xml")
    response = Net::HTTP.post_form( base_uri, api_version: '3',
                                              api_key: EIGHT_TRACK_API_KEY,
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

  def get_currently_trending_tags
    base_url = "http://8tracks.com/tags.xml?api_key=#{EIGHT_TRACK_API_KEY}"
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
  private

    def parse_user_info_from(xml, parse_hash={})
      parse_hash[:tracks_user_id]         = xml.css('id').first.content
      parse_hash[:tracks_user_name]       = xml.css('login').first.content
      parse_hash[:tracks_user_email]      = xml.css('email').first.content
      parse_hash[:tracks_user_web_path]   = xml.css('web-path').first.content.to_s.prepend(%q(https://8tracks.com))
      parse_hash[:tracks_user_token]      = xml.css('user-token').first.content
      parse_hash[:tracks_user_avatar_url] = parse_img_url_from( xml.css('sq56').first.content)

      validate_hash_value parse_hash
      parse_hash      
    end

    def parse_img_url_from(base_url)
      # http://path/to/imamge_file.jpg?arg1=value1&arg2=value2 => http://path/to/imamge_file.jpg?
      base_url.gsub(/\?.*\z/, '?')
    end

    def validate_hash_value(hash)
      empty_value_keys = []
      hash.each { |key, value| empty_value_keys << key if value.nil? }
      raise "Nil value for key: #{empty_value_keys}" if empty_value_keys.any?
    end
end