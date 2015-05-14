require "spec_helper"

RSpec.describe "home", :js => true, :type => :feature do
  include Capybara::Angular::DSL

  before do
    visit "/"
  end
  
  it "contains links to other pages" do
    expect(page).to have_selector ".home-page"
    within ".home-page" do
      expect(page).to have_selector "a[href='/#/work']"
    end
  end
end
