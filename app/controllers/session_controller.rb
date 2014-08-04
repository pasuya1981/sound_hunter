class SessionController < ApplicationController

  include TracksDsl # concern module

  

  def new
    @user = User.new
    @submit_btn_name = "登入"
  end

  def create
    # find user from db
    error_hash = parse_user_params
    if error_hash
      flash[:warning] = error_hash[:errors].join(', ')
      redirect_to login_path
      return
    end

    email = user_params[:email]
    user = User.find_by(email: email)
    
    if user # user is in DB already
      user_session_setup_for(user)
      redirect_to home_path
    else # no user in DB
      user_info_hash = log_user_to_8tracks(email, user_params[:password])
      user_info_hash[:tracks_user_password] = user_params[:password]
      user = new_user_from(user_info_hash)

      if user.save
        user_session_setup_for(user)
        redirect_to home_path
      elsif user.errors.any?# if get nil token, just render 'new'
        flash[:info] = user.errors.full_messages.join(', ')
        redirect_to login_path
      else
        flash[:warning] = "無法處理的問題"
        redirect_to login_path
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
    redirect_to login_path
  end

  # render 'form'. POST to session#create_eight_tracks_account
  def signup
    @user = User.new
    @submit_btn_name = "建立帳號"
  end

  def create_eight_tracks_account
    username = user_params[:username]
    email = user_params[:email]
    password = user_params[:password]

    user_info_hash = signup_user_to_8tracks(username, email, password)

    # 8tracks user signup successfully
    if user_info_hash && user_info_hash[:error].nil? 
      user_info_hash[:tracks_user_password] = user_params[:password]
      user = new_user_from(user_info_hash)
      # user save successfully
      if user.save 
        user_session_setup_for(user)
        redirect_to(home_path)
      # user already exist
      elsif User.exists?(username: user.username, email: user.email) 
        user_session_setup_for(user)
        redirect_to(home_path)
      # DB fails to save user
      else 
        redirect_to signup_path
      end
    # 8tracks returns error for user creation
    elsif user_info_hash[:error]
      flash[:warning] = "8tracks帳號申請錯誤: #{user_info_hash[:error]}"
      redirect_to signup_path
    # no idea what is the error
    else
      flash[:danger] = "不知明的錯誤....#{user_info_hash}"
      redirect_to signup_path
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