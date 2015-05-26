require "spec_helper"
require 'yaml'

RSpec.describe "work", :js => true, :type => :feature do
  before do
    visit "/#/work"
  end

  let :work_data do
    work_file = get_data_file("work.yml")
    YAML.load_file(work_file)
  end
  
  it "renders work template" do
    expect(page).to have_selector ".page-container .work-page" 
  end

  it "displays one container for each work description" do
    jobs = page.all ".work-container"
    data_job_count = work_data["descriptions"].length
    expect(jobs.count).to be(data_job_count)
  end

  it "displays job properties from data/work.yml" do
   text_properties = [
      "name",
      "position",
      "start_date",
      "end_date",
      "location",
      "text"
    ]
    image_properties = [
      "image"
    ]

    jobs = page.all(".work-container")
    work_data["descriptions"].each_with_index do |data_job, index|
      page_job = jobs[index]

      text_properties.each do |prop|
        expect(data_job).to have_key(prop)
        expect(page_job).to have_text(data_job[prop])
      end

      image_properties.each do |prop|
        expect(data_job).to have_key(prop)
        expect(page_job).to have_selector(
          "img[src='/images/#{data_job[prop]}']"
        )
      end
    end
  end

  it "displays extra properties from data/work.yml" do
    jobs = page.all(".work-container")
    work_data["descriptions"].each_with_index do |data_job, index|
      next unless data_job["extras"]

      page_job = jobs[index]

      within page_job do
        data_job["extras"].each do |extra|
          case extra["type"]
          when "link"
            expect(page_job).to have_link(extra["label"], extra["href"])
          when "embed"
            content_link = extra["content_file"]
            selector = ".extras [ng-include=\"'#{content_link}'\"]"

            expect(page_job).to have_no_selector(selector)
            click_on extra["label"]
            expect(page_job).to have_selector(selector)
            click_on extra["label"]
            expect(page_job).to have_no_selector(selector)
          end
        end
      end
    end
  end
end
