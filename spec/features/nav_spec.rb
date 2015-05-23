require "spec_helper"

RSpec.describe "nav", :js => true, :type => :feature do
  include Capybara::Angular::DSL

  before do
    visit "/"
  end
  
  it "contains links to top-level pages" do
    page_names = get_page_names
    page_names[page_names.index("home")] = ""

    expect(page).to have_selector ".navbar"
    page_names.each do |page_name|
      expect(page).to have_selector ".navbar a[href='/#/#{page_name}']"
    end
  end
end
