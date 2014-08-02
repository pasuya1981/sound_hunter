# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  username   :string(255)
#  email      :string(255)
#  password   :string(255)
#  user_token :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  validates_presence_of :password, :email, message: '不能為空白'
  validates_uniqueness_of :email
end
