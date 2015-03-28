# Setup directory structure
set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Import Bower assests
require 'rake/file_list'
require 'pathname'

bower_directory = 'bower_components'
sprockets.append_path File.join root, bower_directory

# Build search patterns
patterns = [
  '.png',  '.gif', '.jpg', '.jpeg', '.svg', # Images
  '.eot',  '.otf', '.svc', '.woff', '.woff2', '.ttf', # Fonts
  '.js',                                    # Javascript
].map { |e| File.join(bower_directory, "**", "*#{e}" ) }

# Create file list and exclude unwanted files
Rake::FileList.new(*patterns) do |l|
  l.exclude(/src/)
  l.exclude(/test/)
  l.exclude(/demo/)
  l.exclude { |f| !File.file? f }
end.each do |f|
  # Import relative paths
  sprockets.import_asset(Pathname.new(f).relative_path_from(Pathname.new(bower_directory)))
end

# Layouts
set :layout, false
page "pages/*", :layout => :page_layout

helpers do
  def get_templates(dirname='')
    base_dir = Pathname(File.join(File.dirname(__FILE__), "source"))
    target_dir = Dir[File.join(base_dir, dirname, "*")]
    target_dir.select { |filename|
      File.file?(filename)
    }.map { |filename|
      template_name = File.basename(filename, '.*')
      template_path = Pathname(File.join(File.dirname(filename), template_name))
      Pathname(template_path).relative_path_from(base_dir).to_s
    }
  end

  def partial_with_layout(partial_name, layout_name)
    wrap_layout layout_name do
      @page_url = "/" + partial_name
      partial @page_url
    end 
  end
end

configure :development do
  set :debug_assets, true
end

configure :build do

  activate :minify_html

  activate :minify_css

  activate :minify_javascript

  activate :gzip

  activate :asset_hash

  activate :relative_assets
end
