class SessionController < ApplicationController
  include TracksDsl # concern module

  # layout 'form'

  def new
    @user = User.new
    @submit_btn_name = "登入"
  end

  def create
    # find user from db
    email = user_params[:email]
    password = user_params[:password]
    user = User.find_by(email: email)

    # if find user, check session[:user_token] and redirect to home_path
    if user
      session[:user_token] = user.tracks_user_token
      redirect_to home_path, notice: "#{user.username} 你好! 您已成功登入"
    else # can't find user from DB, try log in onto 8tracks
      log_user_to_8_tracks(email, password) do |tracks_user_id, tracks_user_name, tracks_user_web_path, tracks_user_token, avatra_url|

        if tracks_user_token && tracks_user_id && tracks_user_web_path && avatra_url # if get user-token, save the user to db with the token
          User.create!(username: tracks_user_name, 
                       email: user_params[:email], 
                       password: user_params[:password],
                       tracks_user_id: tracks_user_id,
                       tracks_user_web_path: tracks_user_web_path,
                       tracks_user_token: tracks_user_token,
                       tracks_user_avatar_url: avatra_url)

          session[:user_token] = tracks_user_token
          redirect_to(home_path, notice: "你好, #{tracks_user_name.capitalize}")
        elsif tracks_user_token.nil? # if get nil token, just render 'new'
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
    redirect_to home_path
  end

  def signup # render form, POST #create_8_tracks_ac
    @user = User.new
    @submit_btn_name = "建立帳號"
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
      user_token = log_user_to_8_tracks( user_params[:email], user_params[:password] )
      return user = User.new(user_params) if user_token && ( user.tracks_user_token = user_token )
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :username)
    end
end
