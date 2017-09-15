require "colorize"
require "yaml"

module Helptransl8
  class Config
    def init(url : String)
      if url
        puts "Created #{"helptransl8.yml".colorize(:green)}"
        File.write Helptransl8::HELPTRANSL8_YML, <<-YAML
--- # Url for origin repo to translate
url: #{url}

YAML
      else
        puts "Add url param"
      end
    end

    def print
      if File.exists? Helptransl8::HELPTRANSL8_YML
        YAML.parse_all(File.read(Helptransl8::HELPTRANSL8_YML)).each do |yaml|
          puts yaml["url"]
        end
      else
        puts "#{"Helptransl8::HELPTRANSL8_YML".colorize(:red)} does not exists!"
        exit 1
      end
    end
  end
end
