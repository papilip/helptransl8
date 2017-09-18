require "./helptransl8/*"
require "option_parser"

ENV["CRYSTAL_ENV"] ||= ""

OptionParser.parse! do |parser|
  parser.banner = <<-BANNER
  HelpTransl8 helps translators check the original documentation repository by comparing each file and listing the files that have been modified

  Usage: helptransl8 [arguments]
  BANNER

  parser.invalid_option do
    puts parser
  end

  parser.unknown_args do
    # puts parser
  end

  parser.on(short_flag:  "-c"
           ,long_flag:   "--check"
           ,description: "Check each file with the original repository"
           ) do
    Helptransl8::Check.new.run
  end

  parser.on(short_flag:  "-h"
           ,long_flag:   "--help"
           ,description: "Show this help"
           ) do
    puts parser
  end

  parser.on(short_flag:  "-i URL"
           ,long_flag:   "--init=URL"
           ,description: "Generates the helptransl8.yml file with original repository url"
           ) do |url|
    Helptransl8::Config.new.init url
  end

  parser.on(short_flag:  "-p"
           ,long_flag:   "--print"
           ,description: "Print URL from original repository"
           ) do
    Helptransl8::Config.new.print
  end

  parser.on(short_flag:  "-v"
           ,long_flag:   "--version"
           ,description: "Shows the version"
           ) do
    puts "Helptransl8 (#{Helptransl8::VERSION})"
  end
end
