require "middleman"
require "capybara/rspec"
require 'capybara/poltergeist'
require 'capybara/angular'

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
end

Capybara.javascript_driver = :poltergeist
Capybara.ignore_hidden_elements = false
Capybara.app = Middleman::Application.server.inst do
  set :debug_assets, true
  set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
  set :environment, :test
  set :show_exceptions, true
end

# Get name of page from filename before .html.erb
def get_page_names
  files = Dir[File.join(
    File.dirname(__FILE__),
    '..',
    "source/pages/*.html*"
  )]
  files.map do |filepath|
    filename = File.basename(filepath)
    filename.split(".").first
  end
end
