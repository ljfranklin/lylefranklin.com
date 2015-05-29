# Adapted from https://gist.github.com/Arcovion/2586eb92389967715da4
class Middleman::Extensions::DirManager < Middleman::Extension
  register :dir_manager
  option :remap_resources, [
    {
      new_dir: "spec/fixtures/blog",
      old_dir: "source/blog"
    }
  ]
 
  def manipulate_resource_list resources
    options[:remap_resources].each do |opts|

      old_dir = normalize(opts[:old_dir])
      new_dir = normalize(opts[:new_dir])

      raise "Dir to replace must be inside source_dir" unless old_dir.include? app.source_dir

      resources.reject! do |page|
        Dir.glob(old_dir + '/*', File::FNM_DOTMATCH).include? page.source_file
      end

      all_new_files = Dir.glob(new_dir + '/**/*', File::FNM_DOTMATCH)
      all_new_files.reject! { |f| File.directory? f }

      new_resources = all_new_files.map do |sourcepath|
        relative_path = Pathname(sourcepath).relative_path_from Pathname(new_dir)
        resource_name = app.sitemap.extensionless_path relative_path

        unless app.source_dir == old_dir
          relative_path = Pathname(old_dir).relative_path_from Pathname(app.source_dir)
          resource_name = File.join relative_path, resource_name
        end

        Middleman::Sitemap::Resource.new app.sitemap, resource_name, sourcepath
      end

      resources.concat new_resources
    end

    resources
  end
 
  private
 
  def normalize directory
    if Pathname(directory).relative?
      File.expand_path File.join app.root, directory
    else
      File.expand_path directory
    end
  end
end
