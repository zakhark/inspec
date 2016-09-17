require 'pry'

files = Dir["*"].map { |f| File.expand_path(f) }

files.each do |f|
  if File.file?(f)
    path = Pathname.new(f)
    new  = File.join(path.dirname, "c:\\#{path.basename}")
    FileUtils.cp(f, new)
  end
end
