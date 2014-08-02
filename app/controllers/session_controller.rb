class SessionController < ApplicationController
  require 'nokogiri'
  require 'open-uri'

  # layout 'form'
  # SoundCloud credientials
  #CLIENT_ID = '90dc4f7f5b8f96149559894d9b7c2068'
  #CLIENT_SECRET =  '54dd0ecd6790e0bc3f5a6283b030111d'

  EIGHT_TRACK_API_KEY = '2b312afc2b28ba56a745c53b49f9288c05f20150'

  def index
  end

  def new
    @user = User.new
  end

  def login
    user_token = get_8_tracks_user_token(user_params[:email], user_params[:password])
    if user_token.present?
      session[:user_token] = user_token 
      redirect_to(home_path, notice: '成功登入')
    else
      @user = User.new
      flash.now[:info] = '申請帳號?'
      render 'new'
    end
  end

  def create
    user_from_db = fetch_user_from_db
    user_from_new = create_temp_new_user unless user_from_db

    respond_to do |format|
      if user_from_new
        if user_from_new.save
          session[:user_id] = user_from_new.id
          format.html { redirect_to home_path, notice: '已成功登入' }
        else
          session[:user_id] = nil
          format.html { render 'new', flash[:error].now = '使用者建立失' }
        end
      elsif user_from_db
        session[:user_id] = user_from_db.id
        format.html { redirect_to home_path, notice: '已成功登入' }
      else
        session[:user_id] = nil
        flash.now[:notcie] = '請申請 8tracks 帳號'
        format.html { render 'new'}
      end
    end
  end

  def logout
    clear_user_token
    redirect_to home_path
  end

  def sign_up
    @user = User.new
  end

  def create_8_tracks_ac
    
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

    def fetch_user_from_db
      user_id = session[:user_id]
      return User.find(user_id) if User.ids.include?(user_id)
      return nil
    end

    def create_temp_new_user
      user_token = get_8_tracks_user_token( user_params[:email], user_params[:password] )
      return user = User.new(user_params) if user_token && ( user.user_token = user_token )
    end

    def sign_up_to_8_tracks(user_name, email, password)
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
        user_token = session[:user_token] = xml.css('user_token').first.content
        return user_token
      else
        return nil
      end
    end 

    # this ensures user has account on 8 tracks (  or just get bad http response )
    def get_8_tracks_user_token(account_name, password)
      # HTTP post requst flow
      base_uri = URI("https://8tracks.com/sessions.xml")
      response = Net::HTTP.post_form( base_uri, login: account_name, 
                                                password: password,
                                                api_version: '3',
                                                api_key: EIGHT_TRACK_API_KEY )
      xml = Nokogiri::XML(response.body)
      response_msg = xml.css('status').first.content
      return user_token = xml.css('user-token').first.content if response_msg =~ /200 ok/i
      return nil 
    end
    
    def user_params
      params.require(:user).permit(:email, :password, :username)
    end
end
