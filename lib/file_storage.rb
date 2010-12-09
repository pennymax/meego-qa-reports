class FileStorage

  def initialize(dir = "public/files", baseurl = "/files/")
    @dir = dir
    @baseurl = baseurl
  end

  def add_file(model, file, name)
    dir = get_directory(model, true)
    target = get_file_path(dir, name)
    FileUtils.copy(file.path, target)
    FileUtils.chmod(0755, target)
  end

  def remove_file(model, name)
    dir = get_directory(model)
    FileUtils.rm(get_file_path(dir, name))
  end

  def list_files(model)
    Dir[File.join(get_directory(model, false).path, '*')].entries.map{|file|
      path = file.slice(@dir.length+1, file.length)
      {   :name => File.basename(file),
          :path => path,
          :url => @baseurl + path
      }
    }
  end

  private
  def get_file_path(dir, name)
    dir.path + "/" + name.gsub(/[^0-9A-Za-z.\-]/, '')
  end

  def get_directory(model, create = false)
    path = @dir + "/" + model.class.table_name + "/" + model.id.to_s + "/"
    if !File.directory?(path) || create
      FileUtils.mkdir_p(path, :mode => 0755)
    end
    Dir.new(path)
  end  
end