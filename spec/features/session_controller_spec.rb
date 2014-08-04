require 'rails_helper'

#  RSpec.describe SessionController, :type => :controller do
#    
#    describe "Get #new" do
#      it "responds with an HTTP 200 status code" do
#        visit :new
#        puts response.methods
#      end
#    end
#  end	

describe SessionController do
  describe "Get #new" do
    before :each do
      visit login_path
    end
    it "responds with an HTTP 200 status code" do
      visit login_path
      expect(page).to have_content '登入'
    end

    it "get error press button" do
      click_button("登入")
      expect(page).to have_content('success')
    end

    it "try signup" do
      visit signup_path
      click_button "建立帳號"
      expect(page).to have_content("建立帳號")
    end
  end
end	