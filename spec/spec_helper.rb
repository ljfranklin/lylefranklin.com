require "middleman"
require "capybara/rspec"
require 'capybara/poltergeist'
require 'capybara/angular'
require_relative '../dir_manager'

# Need to reload Middleman plugins
require 'middleman-blog'
require 'middleman-sprockets'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # default in RSpec 4
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # default in RSpec 4
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.order = :random

  Kernel.srand config.seed

  if ENV["APP_URL"]
    config.filter_run_excluding :local_only => true
  end
end

def root_dir
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

Capybara.ignore_hidden_elements = false

if ENV["APP_URL"]
  Capybara.run_server = false
  Capybara.app_host = ENV["APP_URL"]
  Capybara.javascript_driver = :selenium
  Capybara.default_driver = :selenium
else
  Capybara.javascript_driver = :poltergeist
  Capybara.app = Middleman::Application.server.inst do
    set :debug_assets, true
    set :root, root_dir
    set :environment, :test
    set :show_exceptions, true

    before_configuration do
      activate :dir_manager
      config[:blog_per_page] = 2
    end
  end
end

# Get name of page from filename before .html.erb
def get_page_names
  files = Dir[File.join(
    root_dir,
    "source/pages/*.html*"
  )]
  files.map do |filepath|
    filename = File.basename(filepath)
    filename.split(".").first
  end
end

def get_data_file(filename)
  File.join(
    root_dir,
    "data",
    filename
  )
end
