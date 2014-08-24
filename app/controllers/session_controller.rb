class SessionController < ApplicationController

  layout 'mixes'

  def new
    @user = User.new
    @submit_btn_name = "登入"
    respond_to do |format|
      format.html { redirect_to home_path }
      format.js
    end
  end

  def create
    email = user_params[:email]
    user = User.find_by(email: email)
     
    respond_to do |format|
      unless make_sure_user_params_are_all_present
        flash.now[:info] = "帳號或密碼不能為空白"
        format.html { redirect_to login_path } 
        @error = "帳號或密碼不能為空白"
        format.js {  @error }
        return
      end
      
      if user # user is in DB already
        if !user.authenticate(user_params[:password])
          @error = "密碼錯誤"
          format.html { redirect_to login_path }
          format.js { @error }
          return
        end
        user_session_setup_for(user)
        return_to = session[:return_to_url]
        if return_to.present?
          session[:return_to_url] = nil
          format.html { redirect_to return_to }
          format.js do
            puts "AJAX on session#create. Reason: User login succeed and has return-to-url.".red
            @render_path = return_to
          end
        else
          format.html { redirect_to home_path }
          format.js do 
            puts "AJAX on session#create. Reason: no return to link, go home path".red
            @render_path = "home"
          end
        end
      else # no user in DB, search from 8track server

        user_info_hash = EightTracksParser.log_user_to_8tracks(email, user_params[:password])
        # no account on 8tracks server
        if user_info_hash.nil?
          @error = "帳號或密碼錯誤"
          format.html { redirect_to login_path } 
          format.js { @error }
          return
        end
        user_info_hash[:tracks_user_password] = user_params[:password]
        user = new_user_from(user_info_hash)  

        if user.save
          user_session_setup_for(user)
          format.html { redirect_to home_path } 
          format.js { puts "AJAX on session#create. Reason: successfully get a user info from 8tracks server and save it on DB".red }
        elsif user.errors.any?# if get nil token, just render 'new'
          @error = user.errors.full_messages.join(', ')
          format.html { redirect_to login_path }  
          format.js { puts "AJAX on session#create. Reason: find a user from 8tracks server but can not save user to DB".red; @error }
        else
          @error = "無法處理的問題"
          format.html { redirect_to login_path } 
          format.js { @error }
        end
      end
    end
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

  def logout
    clear_user_token
    respond_to do |format|
      format.html { redirect_to login_path }
      format.js
    end
  end

  # render 'form'. POST to session#create_eight_tracks_account
  def signup
    @user = User.new
    @submit_btn_name = "建立帳號"
  end

  def create_eight_tracks_account
    username = user_params[:username]
    email    = user_params[:email]
    password = user_params[:password]
    puts "Usename: #{username}, email: #{email}, password: #{password}".red

    user_info_hash = EightTracksParser.signup_user_to_8tracks(username, email, password)

    unless request.xhr?
      redirect_to home_path
      return
    end

    respond_to do |format|
      # 8tracks user signup successfully
      if user_info_hash && user_info_hash[:error].nil? 
        user_info_hash[:tracks_user_password] = user_params[:password]
        user = new_user_from(user_info_hash)
        # user save successfully
        if user.save 
          user_session_setup_for(user)
          @message = "成功建立帳號 #{username} #{email}"
          format.js { @message }
        # user already exist
        elsif User.exists?(username: user.username, email: user.email) 
          user_session_setup_for(user)
          @message = "帳號已存在，直接登入. #{username} #{email}"
          format.js { @message }
        # DB fails to save user
        else 
          @error = "成功在8tracks申請帳號，但Local DB存入失敗"
          format.js { @error }
        end
      # 8tracks returns error for user creation
      elsif user_info_hash[:error]
        @error = "8tracks帳號申請錯誤: #{user_info_hash[:error]}"
        format.js { @error }
      # no idea what is the error
      else
        @error = "不知明的錯誤....#{user_info_hash}"
        format.js { @error }
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
  EMAIL_REGEXP = /^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/

  # Check for text string to have atleast one Numeric 
  # and one Character and the  length of text string to be 
  # between 4 to 8 characters
  PASSWORD_REGEXP = /^(?=.*\d)(?=.*[a-zA-Z]).{4,8}$/

    def make_sure_user_params_are_all_present
      return false if user_params[:email].size < 1 || user_params[:password].size < 1
      return true
    end

    # This method is abandoned.
    def parse_user_params
      error = { errors: [] }
      error[:errors] << 'Email格式錯誤' unless user_params[:email].to_s =~ EMAIL_REGEXP
      error[:errors] << "密碼需包含一數字一字母，字數介於4-8之間" unless user_params[:password] =~ PASSWORD_REGEXP
      if User.exists?(email: user_params[:email])
        error[:errors] << "密碼錯誤" unless User.find_by(email: user_params[:email]).authenticate(user_params[:password])
      else
        error[:errors] << "無此帳號" unless User.exists?(email: user_params[:email])
      end
      return error if error[:errors].any?
      return nil
    end

    def new_user_from(user_info_hash)
      User.new(username:               user_info_hash[:tracks_user_name], 
               tracks_user_id:         user_info_hash[:tracks_user_id],
               email:                  user_info_hash[:tracks_user_email],
               password:               user_info_hash[:tracks_user_password],
               tracks_user_token:      user_info_hash[:tracks_user_token], 
               tracks_user_web_path:   user_info_hash[:tracks_user_web_path], 
               tracks_user_avatar_url: user_info_hash[:tracks_user_avatar_url])
    end

    def fetch_user_from_db
      user_id = session[:user_id]
      return User.find(user_id) if User.ids.include?(user_id)
      return nil
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :username)
    end
end