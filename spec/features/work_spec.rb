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
    html_properties = [
      "extras"
    ]

    jobs = page.all ".work-container"
    data_job_count = work_data["descriptions"].length
    expect(jobs.count).to be(data_job_count)

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

      html_properties.each do |prop|
        expect(data_job).to have_key(prop)
        # could not find method to get html of page_job
        expect(page.body).to include(data_job[prop])
      end
    end
  end
end
