require "spec_helper"

RSpec.describe "loading", :js => true, :type => :feature do
  before do
    visit "/#/about"
  end
  
  it "renders about template" do
    expect(page).to have_selector ".page-container .about-page" 
  end
end
