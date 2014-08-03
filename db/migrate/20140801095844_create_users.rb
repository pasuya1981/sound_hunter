class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :username
      t.string  :email
      t.string  :password_digest
      t.string  :tracks_user_token
      t.integer :tracks_user_id
      t.string  :tracks_user_web_path
      t.string  :tracks_user_avatar_url

      t.timestamps
    end
  end
end
