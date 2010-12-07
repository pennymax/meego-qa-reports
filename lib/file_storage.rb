class FileStorage
  def initialize(dir)
    @dir = dir
  end

  def add_file(model, file, name)
    dir = get_directory(model, true)
    FileUtils.copy(file.path, dir.path + "/" + name.gsub!(/[^0-9A-Za-z.\-]/, ''))
  end

  def list_files(model)
    Dir[File.join(get_directory(model, false).path, '*')].entries.map{|file|
      {
          :name => File.basename(file),
          :path => file.slice!(@dir.length+1, file.length)
      }      
    }
  end

  private
  def get_directory(model, create = false)
    path = @dir + "/" + model.table_name() + "/" + model.id.to_s + "/"

    if !File.directory?(path) || create
      FileUtils.mkdir_p(path)
    end
    Dir.new(path)
  end  
end