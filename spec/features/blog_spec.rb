require "spec_helper"

RSpec.describe "blog", :js => true, :type => :feature do
  before do
    visit "/#/blog"
  end

  let(:posts_per_page) { 2 }
  
  it "renders about template" do
    expect(page).to have_selector ".page-container .blog-page" 
  end

  it "displays first page of blog posts" do
    expect(page).to have_selector ".blog-page .blog-post", count: posts_per_page
  end
end
