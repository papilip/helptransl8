require "colorize"
require "yaml"

module Helptransl8
  class Check
    def initialize
      @prefix_dir = ""

      case ENV["CRYSTAL_ENV"]?
      when "devel" || "development" || "test"
        @prefix_dir = "helptransl8_#{ENV["CRYSTAL_ENV"]}_dir/"
        cmds = [] of String
        cmds << "mkdir -p #{@prefix_dir}"
        process_run(cmds)
      else
        @prefix_dir = "./"
      end

      @files = [] of String
      @todos = [] of String
      @url = ""

      if File.exists? Helptransl8::HELPTRANSL8_YML
        YAML.parse_all(File.read(Helptransl8::HELPTRANSL8_YML)).each do |yaml|
          @url = yaml["url"].to_s
        end
      else
        puts "Helptransl8: #{"Helptransl8::HELPTRANSL8_YML".colorize(:red)} does not exists!"
        exit 1
      end
    end

    def check_diff_sha(file, dot_file)
      new_sha = get_sha2("#{@prefix_dir}#{file}")
      old_sha = get_sha2("#{@prefix_dir}#{dot_file}")
      return new_sha == old_sha
    end

    def clone_repository
      cmds = [] of String
      cmds << "rm -rf #{Helptransl8::ORIGINAL_REPO}"
      cmds << "git clone #{@url} #{Helptransl8::ORIGINAL_REPO}"
      cmds << "rm -rf #{Helptransl8::ORIGINAL_REPO}/.git"
      process_run(cmds)
    end

    # brew info sha2
    def get_sha2(file)
      cmd = "sha2 -512 -q #{file}"
      out_io = IO::Memory.new
      err_io = IO::Memory.new
      p = Process.run(cmd, shell: true, output: out_io, error: err_io)
      return out_io.to_s.chomp
    end

    def list_all_files
      Dir["#{Helptransl8::ORIGINAL_REPO}/**/*"].each do |file|
        unless File.directory? file
          basename = File.basename file
          unless basename[0].to_s == "."
            paths = file.split("/")
            paths.delete_at 0
            @files << paths.join "/"
          end
        end
      end
    end

    def prepare_commands
      cmds = [] of String

      @files.each do |file|
        paths = file.split("/")
        name = paths.delete_at -1
        path = paths.join "/"
        if path.blank?
          dot_file = ".#{name}"
        else
          dot_file = "#{path}/.#{name}"
        end

        if File.exists? "#{@prefix_dir}#{file}"
          # Test si le fichier dot existe et s’il y a des différences
          unless File.exists?("#{@prefix_dir}#{dot_file}") && check_diff_sha(file, dot_file)
            @todos << file
            cmds << "cp #{Helptransl8::ORIGINAL_REPO}/#{file} #{@prefix_dir}#{dot_file}"
          end
        else
          @todos << file
          # Déplace le fichier et le copie en dot file
          mkdir_path = "#{@prefix_dir}#{path}"
          cmds << "mkdir -p #{mkdir_path}" unless mkdir_path.blank?
          cmds << "cp #{Helptransl8::ORIGINAL_REPO}/#{file} #{@prefix_dir}#{file}"
          cmds << "cp #{@prefix_dir}#{file} #{@prefix_dir}#{dot_file}"
          # cmds << "=" * 77
        end
      end

      return cmds
    end

    def process_run(cmds)
      puts "-" * 77 if ENV["CRYSTAL_ENV"]
      cmds.each do |cmd|
        puts cmd
        p = Process.run(cmd, shell: true)
        unless p.success?
          puts "Helptransl8: Command <#{cmd}> failed"
          exit 1
        end
      end
    end

    def run
      clone_repository
      list_all_files
      cmds = prepare_commands
      write_todo unless @todos.empty?
      cmds << "rm -rf #{Helptransl8::ORIGINAL_REPO}" unless ENV["CRYSTAL_ENV"]
      process_run(cmds)
    end

    def write_todo
      file = "#{@prefix_dir}#{Helptransl8::TODO_FILE}"
      if File.exists? file
        cmds = [] of String
        cmds << "mv #{file} #{@prefix_dir}#{Time.new.to_s("%Y_%m_%d-%H_%M")}-#{Helptransl8::TODO_FILE}"
        process_run(cmds)
      end
      File.write(file, @todos.to_yaml)
    end
  end
end
