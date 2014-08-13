# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  username               :string(255)
#  email                  :string(255)
#  password_digest        :string(255)
#  tracks_user_token      :string(255)
#  tracks_user_id         :integer
#  tracks_user_web_path   :string(255)
#  tracks_user_avatar_url :string(255)
#  tracks_user_play_token :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

class User < ActiveRecord::Base

  has_secure_password
  validates_presence_of :password
  validates_presence_of :email
  validates_presence_of :tracks_user_token
  validates_uniqueness_of :email

  def self.spawn
    create(username: 'pasuya1981', email: 'fake@fake.com', password: 'fakepassword', tracks_user_token: 'token_string_5678')
  end
end
