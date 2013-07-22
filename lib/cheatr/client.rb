require "yaml"
require "pager"
require "cheatr/client/sheet"

module Cheatr
  module Client
    extend Pager

    # Actions

    def self.search_sheets(query = nil)
      query += '*' unless query.nil? || query.include?('*')
      page
      puts Sheet.all(query)
    end

    def self.display_sheet(name, opts = {})
      sheet = Sheet.new(name, opts)
      if sheet.contents
        page
        puts "(cached version)" unless sheet.remote?
        puts sheet.contents
      else
        puts sheet.errors.first
      end
    end

    def self.edit_sheet(name, opts = {})
      sheet = Sheet.new(name, ignore_cache: true)

      file = Tempfile.new([name, '.md'])
      file.write(sheet.contents) if sheet.contents
      file.close
      system "#{editor} #{file.path}"
      file.open
      contents = file.read
      file.close

      if contents.strip.empty?
        puts "Edited sheet contents were empty so nothing was saved."
        return
      end

      if opts[:skip_confirmation] || confirm("Do you want to update the '#{name}' cheat sheet?")
        sheet.contents = contents
        if sheet.save
          puts "Sheet '#{name}' was updated successfully."
        else
          puts "Sheet '#{name}' could not be updated."
          $stderr.puts "Error: #{sheet.errors.first}" if sheet.errors
        end
      else
        puts "Sheet '#{name}' was left unchanged."
      end
    end

    def self.browse(query = nil)
      open_cmd = `uname` =~ /Darwin/ ? 'open' : 'xdg-open'
      uri = "http://#{server}/#{query}"
      exec "#{open_cmd} #{uri}"
    end

    def self.fetch_sheets(arr, opts = {})
      arr.each do |name|
        sheet = Sheet.new(name, ignore_cache: true)
        if sheet.contents
          puts "Sheet '#{name}' fetched successfully." unless opts[:quiet] || opts[:errors]
        else
          message = sheet.errors.first || "Sheet '#{name}' could not be fetched."
          puts message unless opts[:quiet]
        end
      end
    end

    def self.clear_cache(name = :all, opts = {})
      if name == :all
        if opts[:quiet] || opts[:skip_confirmation] || confirm("Are you sure you want clear all cheat sheets cache?")
          FileUtils.rm Dir.glob("#{cache_dir}/*.md")
          puts "All cached cheat sheets have been removed." unless opts[:quiet]
        else
          puts "Cached cheat sheets were not removed." unless opts[:quiet]
        end
      else
        FileUtils.rm "#{cache_dir}/#{name}.md", force: true
        puts "Removed cached version of '#{name}'." unless opts[:quiet]
      end
    end

    # Configuration settings

    def self.mkdir(dir)
      FileUtils.mkdir_p dir
      dir
    end

    def self.cheatr_dir
      @@cheatr_dir ||= mkdir File.join(File.expand_path("~"), ".cheatr")
    end

    def self.cache_dir
      @@cache_dir ||= mkdir File.join(cheatr_dir, 'cache', server.gsub(/:\d+\z/, ''))
    end

    def self.server
      @@sever ||= config['server']
    end

    def self.editor
      @@editor ||= ENV['EDITOR']
    end

    def self.config_file
      @@config_file ||= File.join(cheatr_dir, 'config.yml')
    end

    def self.config
      @@config ||= YAML.load_file(config_file) || {} rescue {}
    end

    def self.set_config(options)
      config.merge!(options)
      File.open(config_file, 'w') { |f| f.write config.to_yaml }
    end

    private

    def self.confirm(message)
      print "#{message} (yes/no) "
      answer = $stdin.gets.chomp
      %w(yes Yes YES y Y).include? answer
    end
  end
end
