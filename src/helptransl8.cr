require "./helptransl8/*"
require "option_parser"

OptionParser.parse! do |parser|
  parser.banner = <<-BANNER
HelpTransl8 helps translators check the original documentation repository by comparing each file and listing the files that have been modified

Usage: helptransl8 [arguments]
BANNER
  parser.invalid_option { puts parser }

  parser.on("-c", "--check", "Check each file with the original repository") { puts "check" }

  parser.on("-h", "--help", "Show this help") { puts parser }

  parser.on "-i URL", "--init=URL", "Generates the helptransl8.yml file with original repo url" do |url|
    Helptransl8::Generator.new.init url
  end

  parser.on "-v", "--version", "Shows the version" do
    puts "Helptransl8 (#{Helptransl8::VERSION})"
  end
end
