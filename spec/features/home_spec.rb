require "spec_helper"

RSpec.describe "home", :js => true, :type => :feature do
  include Capybara::Angular::DSL

  before do
    visit "/"
  end
  
  it "contains links to top-level pages" do
    page_names = get_page_names - ["home"]

    expect(page).to have_selector ".home-page"
    page_names.each do |page_name|
      expect(page).to have_selector ".home-page a[href='/#/#{page_name}']"
    end
  end

  it "contains templates for top-level pages" do
    get_page_names.each do |page_name|
      expect(page).to have_selector(
        :xpath,
        "//script[@id='/pages/#{page_name}/'][@type='text/ng-template']"
      )
    end
  end
end
