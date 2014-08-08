require 'rails_helper'

RSpec.describe SearchController, :type => :controller do

  describe "GET search" do
    it "returns http success" do
      get :search
      expect(response).to be_success
    end
  end

  describe "GET result" do
    it "returns http success" do
      get :result
      expect(response).to be_success
    end
  end

end
