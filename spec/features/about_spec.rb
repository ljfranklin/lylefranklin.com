require "spec_helper"

RSpec.describe "about", :js => true, :type => :feature do
  include Capybara::Angular::DSL

  before do
    visit "/#/about"
  end
  
  it "renders about template" do
    expect(page).to have_selector ".page-container .about-page" 
  end
end
