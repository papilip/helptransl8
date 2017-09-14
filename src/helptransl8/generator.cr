require "yaml"
require "colorize"

module Helptransl8
  class Generator
    def init(url : String)
      file = "./helptransl8.yml"
      if url
        puts "Created #{"helptransl8.yml".colorize(:green)}"
        File.write file, <<-YAML
--- # Url for origin repo to translate
url: #{url}

YAML
      else
        puts "Add url param"
      end
    end
  end
end
