require "spec_helper"

RSpec.describe "loading", :type => :feature do
  before do
    visit "/"
  end
  
  it "displays loading icon before JS loads", :js => false do
    expect(page).to have_selector(".loading-container", visible: true) 
  end

  it "hides loading icon after JS loads", :js => true do
    expect(page).to have_selector(".loading-container.ng-hide", visible: false) 
  end
end
