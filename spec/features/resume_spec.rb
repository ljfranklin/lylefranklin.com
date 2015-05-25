require "spec_helper"

RSpec.describe "resume", :js => true, :type => :feature do
  before do
    visit "/#/resume"
  end
  
  it "renders resume template" do
    expect(page).to have_selector ".page-container .resume-page" 
  end

  it "embeds resume.html" do
    expect(page).to have_text "LYLE FRANKLIN" 
  end
end
