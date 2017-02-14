class Readme < String
  attr_reader :path

  def initialize(path)
    @path = path
    super(File.read(self.path))
  end

  def summary(section = "(?:\\S+)")
    search(section)
  end

  private
  def search(section)
    if self =~ /^#+ #{section}\n\n(.*?)(?:\n\n#|\n\z)/m
      scrub($1)
    else
      raise "could not find #{section} in #{path}"
    end
  end

  def scrub(string)
    string.delete("\\`").gsub(/\[([^\]]+)\]\([^)]*\)/, "\\1").tr("\n", " ").to_s
  end
end

def readme(path = File.expand_path("./README.md"))
  (@readmes ||= {})[path] ||= Readme.new(path)
end
