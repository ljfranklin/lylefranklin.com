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

# Precompile Bootstrap fonts
# sprockets.assets.precompile << %r(bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff2?)$)
# Minimum Sass number precision required by bootstrap-sass
::Sass::Script::Number.precision = [8, ::Sass::Script::Number.precision].max

# Layouts
set :layout, false
page "pages/*", :layout => :page_layout

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end
