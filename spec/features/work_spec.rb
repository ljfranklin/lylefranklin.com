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

  it "displays each job in data/work.yml" do
    jobs = page.all ".work-container"
    data_job_count = work_data["descriptions"].length
    expect(jobs.count).to be(data_job_count)

    work_data["descriptions"].each do |job|

    end
  end
end
