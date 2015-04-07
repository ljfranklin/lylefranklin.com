require 'pathname'

# Setup directory structure
set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'
# Don't build orig images
ignore "images/*.orig.*"

# Import Bower assests
bower_directory = 'bower_components'
sprockets.append_path File.join root, bower_directory

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
