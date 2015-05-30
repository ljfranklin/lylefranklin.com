require "spec_helper"

RSpec.describe "loading", :type => :feature, :js => true do
  before do
    visit "/"
  end

  it "hides loading icon after JS loads" do
    expect(page).to have_selector(".loading-container.ng-hide", visible: false) 
  end
end
