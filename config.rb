require 'rake/file_list'
require 'pathname'

# Setup directory structure
set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'
# Don't build orig images
ignore "images/*.orig.*"

# Don't include vendored styles
ignore "stylesheets/vendor/*"

after_configuration do
  # Import Bower assests
  bower_directory = 'bower_components'
  sprockets.append_path File.join root, bower_directory

  patterns = File.join(bower_directory, "**/*.js")

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
end

# Top-level pages are embedded as ng_templates, layout is done in index
set :layout, false
# Paginated blog post lists are fetched on-demand
page "pages/blog/**/*", :layout => :page_layout

activate :blog do |blog|
  blog.layout = :article_layout
  blog.sources = "{year}-{month}-{day}-{title}.html"
  blog.prefix = "blog"
  blog.paginate = true
  blog.per_page = config[:blog_per_page] || 10
  summary_length = -1
end

activate :directory_indexes

helpers do
  def get_templates(include_patterns, exclude_patterns=[])

    matching_resources = []
    sitemap.resources.each { |current_resource|
      found_match = include_patterns.any? { |pattern|
        File.fnmatch?(pattern, current_resource.request_path, File::FNM_PATHNAME)
      }
      if found_match
        matching_resources = matching_resources | [current_resource]
      end
    }

    matching_resources.each { |resource|
      found_match = exclude_patterns.any? { |pattern|
        File.fnmatch?(pattern, resource.request_path, File::FNM_PATHNAME)
      }
      if found_match
        matching_resources = matching_resources - [resource]
      end
    }

    matching_resources
  end
end

configure :development do
  activate :livereload
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
