class SessionController < ApplicationController
  require 'nokogiri'
  require 'open-uri'

  layout 'form'

  # SoundCloud credientials
  #CLIENT_ID = '90dc4f7f5b8f96149559894d9b7c2068'
  #CLIENT_SECRET =  '54dd0ecd6790e0bc3f5a6283b030111d'

  EIGHT_TRACK_API_KEY = '2b312afc2b28ba56a745c53b49f9288c05f20150'
  TEST_URL = "http://8tracks.com/mixes/1.xml?api_key=#{EIGHT_TRACK_API_KEY}?api_version=3"

  def index
  end

  def new
    @user = User.new
  end

  def create

    # TODO: 8 tracks user authentication flow
    user_token = session[:user_token] || get_8_tracks_user_token(user_params[:email], user_params[:password])
    @user = User.new(user_params, user_token: "user_token")

    respond_to do |format|
      if @user.save
        format.html { redirect_to home_path }
      else
        format.html { render 'new' } 
      end
    end
    
  end

  def edit
  end

  def update
  end

  def delete
  end

  def destroy
  end


  private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def get_8_tracks_user_token(account_name, password)
      base_uri = URI("https://8tracks.com/sessions.xml")
      res = Net::HTTP.post_form( base_uri, login: account_name, 
                                           password: password,
                                           api_version: '3',
                                           api_key: EIGHT_TRACK_API_KEY )
      xml = Nokogiri::XML(res.body)
      redirect_to login_path unless xml.css('status').first.content == '200 OK'
      user_token = xml.css('user-token').first.content
      session[:user_token] = user_token
    end
end
