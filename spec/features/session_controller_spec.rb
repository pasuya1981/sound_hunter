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
    it "responds with an HTTP 200 status code" do
      visit login_path
      expect(page).to have_content '登入'
    end
  end
end	