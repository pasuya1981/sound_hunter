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
    if response_status.to_s =~ /201 created/i
      tracks_user_id = xml.css('id').first.content
      tracks_user_name = xml.css('login').first.content
      tracks_user_web_path = xml.css('web-path').first.content.to_s.prepend(%q(https://8tracks.com))
      tracks_user_token = xml.css('user-token').first.content
      tracks_user_avatar_url = parse_img_url_from( xml.css('sq56').first.content )
      yield(response_status, tracks_user_id, tracks_user_name, tracks_user_web_path, tracks_user_token, tracks_user_avatar_url) if block_given?
      return
    else
      # TODO: faile to create new user flow.
      # Maybe could have create Custom Error Message
      raise response.body
      yield response_status
    end
  end   # this ensures user has account on 8 tracks (  or just get bad http response )

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
      tracks_user_id = xml.css('id').first.content
      tracks_user_name = xml.css('login').first.content
      tracks_user_web_path = xml.css('web-path').first.content.to_s.prepend(%q(https://8tracks.com))
      tracks_user_token = xml.css('user-token').first.content
      tracks_user_avatar_url = parse_img_url_from( xml.css('sq56').first.content )
      yield(tracks_user_id, tracks_user_name, tracks_user_web_path, tracks_user_token, tracks_user_avatar_url) if block_given?
    elsif response_status =~ /422 Unprocessable Entity/i
      yield if block_given?
    end
  end

  def parse_img_url_from(base_url)
    # http://path/to/imamge_file.jpg?arg1=value1&arg2=value2 => http://path/to/imamge_file.jpg?
    base_url.gsub(/\?.*\z/, '?')
  end
end

# Example of 8tracks good auth response
#
#  { user :
#    { user_token : "988;ca9c9d3b8cfc7a60047f5c9d87295b97ac135bd7",
#      id : 988,
#      login : "remitest",
#      web_path : "/remitest",
#      ...
#      }
#    },
#    status : "200 OK",
#    errors : null,
#    notices : "You are now logged in as remitest",
#    logged_in : true,
#    api_version : 3
#  }

# Example of 8tracks bad auth response
#
#  { status : "422 Unprocessable Entity",
#    errors : "Your login was unsuccessful",
#    notices : null,
#    logged_in : false,
#    api_version : 3
#  }