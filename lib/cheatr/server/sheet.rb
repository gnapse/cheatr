require 'git'
require 'active_model'
require 'active_support/core_ext'
require 'cheatr/error'

module Cheatr::Server
  class Sheet
    include ActiveModel::Model

    attr_accessor :name
    validates_presence_of :name, :contents
    validates_format_of :name, with: Cheatr::SHEET_NAME_REGEXP

    def initialize(name)
      super(name: name)
    end

    def human_name
      @human_name ||= name.gsub('.', ' / ')
    end

    def contents
      @contents ||= object.try(:contents)
    end

    def contents=(new_contents)
      @contents = filter_contents(new_contents)
    end

    def save
      return false unless valid?

      git do
        File.open(file_name, 'w') { |f| f.write(contents) }
        git.add(file_name)
        if git.status[file_name].type
          git.commit "#{new? ? 'Create' : 'Update'} #{name}"
          reload
        end
      end

      return true
    rescue => e
      errors.add(:contents, "couldn't be saved (#{e.message})")
      return false
    end

    def reload
      # Forces reloading when getters are invoked
      @object = @contents = nil
    end

    def file_name
      @file_name ||= "#{name}.md"
    end

    def object
      @object ||= git.object("master:#{file_name}")
    rescue
      nil
    end

    def new?
      object.nil?
    end

    # Querying for sheets

    def self.all(query = nil)
      query = "*" if query.nil?
      git.ls_files("#{query}.md").keys.map { |f| Sheet.new f.gsub(/\.md\z/, '') }
    end

    def self.find(name)
      sheet = Sheet.new(name)
      sheet.new? ? nil : sheet
    end

    def self.find!(name)
      find(name) or raise Sinatra::NotFound
    end

    # Git connection

    def self.repository=(path)
      @@repository = path
      git # check if the path is a valid repository
      path
    end

    def self.repository
      @@repository ||= Dir.pwd
    end

    def self.git
      if block_given?
        git.reset_hard
        git.checkout('master')
        git.chdir { yield }
        return
      end
      @@git ||= Git.open(repository) rescue init_repository
    rescue Errno::EEXIST
      raise Cheatr::Error, "Folder #{repository} is not a valid cheatr repository."
    end

    def git(&block)
      self.class.git(&block)
    end

    private

    #
    # Initializes a new cheatr repository at the specified location.
    #
    # The given folder must not exist.
    #
    def self.init_repository
      Dir.mkdir(repository)
      g = Git.init(repository)
      g.chdir do
        File.open('config.ru', 'w') do |f|
          f.write("require 'cheatr'\nrun Cheatr::Server::App\n")
        end
        g.add('config.ru')
        g.commit('Initial commit')
      end
      g
    end

    #
    # Standardizes the contents, specially with regards to newline characters.
    #
    def filter_contents(contents)
      contents.strip.gsub("\r\n", "\n").gsub("\r", "\n") + "\n"
    end

  end
end
