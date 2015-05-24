require "spec_helper"

RSpec.describe "nav", :js => true, :type => :feature do
  include Capybara::Angular::DSL

  it "contains links to top-level pages" do
    visit "/"

    page_names = get_page_names
    page_names[page_names.index("home")] = ""

    expect(page).to have_selector ".navbar"
    page_names.each do |page_name|
      expect(page).to have_selector ".navbar a[href='/#/#{page_name}']"
    end
  end

  it "highlights link of current page" do
    page_names = get_page_names - ["home"]

    page_links = page_names.map do |page_name|
      "/#/#{page_name}"
    end

    page_links.each do |link|
      visit link

      active_link = ".navbar li.active a[href='#{link}']"
      expect(page).to have_selector active_link
    end
  end
end
