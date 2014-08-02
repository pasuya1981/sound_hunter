require 'spec_helper'

RSpec.describe SessionController, :type => :controller do
  
  it 'render login page' do
    visit login_path
  end
end