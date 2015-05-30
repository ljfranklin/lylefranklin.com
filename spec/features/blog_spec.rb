require "spec_helper"

RSpec.describe "blog", :js => true, :type => :feature do
  include Capybara::Angular::DSL

  describe "blog list" do
    before do
      visit "/#/blog"
    end

    let(:posts_per_page) { 2 }
    let(:total_posts) { 4 }

    it "renders about template" do
      expect(page).to have_selector ".page-container .blog-page"
    end

    it "displays first page of blog posts in reverse chron. order", :local_only => true do
      posts_selector = ".blog-page .blog-post"
      expect(page).to have_selector posts_selector, count: posts_per_page

      page.all(posts_selector).each_with_index do |post, index|
        next_post_index = total_posts - index

        expect(post).to have_content "Title #{next_post_index}"
        expect(post).to have_content "Summary #{next_post_index}"
        expect(post).to have_no_content "Body #{next_post_index}"

        post_date = "2015/05/#{next_post_index.to_s.rjust(2, "0")}"
        post_link = "/#/blog/#{post_date}/testing/"
        expect(post).to have_selector "a[href='#{post_link}']"
      end
    end

    it "paginates the blog posts", :local_only => true do
      work_page = page.find ".blog-page"

      expect(work_page).to have_content "Page 1 of 2"

      next_page_link = "/#/blog/page/2/"
      expect(work_page).to have_selector "a[href='#{next_page_link}']"

      work_page.find("a[href='#{next_page_link}']").click

      expect(work_page).to have_content "Page 2 of 2"
      prev_page_link = "/#/blog/"
      expect(work_page).to have_selector "a[href='#{prev_page_link}']"
    end
  end

  describe "blog post", :local_only => true do
    before do
      visit "/#/blog/2015/05/01/testing"
    end

    it "renders blog post template" do
      expect(page).to have_selector ".page-container .blog-post-page"
    end

    it "displays all blog fields" do
      expect(page).to have_content "Title 1"
      expect(page).to have_content "Summary 1"
      expect(page).to have_content "Body 1"
    end

    it "links back to blog list" do
      blog_post_page = page.find ".page-container .blog-post-page"
      expect(blog_post_page).to have_selector "a[href='/#/blog']"
    end
  end
end
