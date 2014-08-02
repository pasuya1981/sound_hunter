class SessionController < ApplicationController
  require 'nokogiri'
  require 'open-uri'

  layout 'form'
  # SoundCloud credientials
  #CLIENT_ID = '90dc4f7f5b8f96149559894d9b7c2068'
  #CLIENT_SECRET =  '54dd0ecd6790e0bc3f5a6283b030111d'

  EIGHT_TRACK_API_KEY = '2b312afc2b28ba56a745c53b49f9288c05f20150'

  def index
  end

  def new
    @user = User.new
  end

  def create
    user = fetch_or_create_user

    respond_to do |format|
      if user.save
        session[:user_id] = user.id
        format.html { redirect_to home_path, notice: '已成功登入' }
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

    def fetch_or_create_user
      begin
        user = User.find(session[:user_id]) if session[:user_id]
      rescue
        session[:user_id] = nil
      end
      if user.nil?
        session[:user_id] = nil
        user_token = get_8_tracks_user_token( user_params[:email], user_params[:password] )
        user = User.new(user_params)
        user.user_token = user_token
      end
      return user
    end

    def get_8_tracks_user_token(account_name, password)
      # HTTP post requst flow
      base_uri = URI("https://8tracks.com/sessions.xml")
      res = Net::HTTP.post_form( base_uri, login: account_name, 
                                           password: password,
                                           api_version: '3',
                                           api_key: EIGHT_TRACK_API_KEY )
      xml = Nokogiri::XML(res.body)
      response_msg = xml.css('status').first.content
      raise "#{response_msg}" unless response_msg == '200 OK'
      user_token = xml.css('user-token').first.content
      logger.info "user_token: #{user_token}"
      return user_token
    end
    
    def user_params
      params.require(:user).permit(:email, :password)
    end
end
