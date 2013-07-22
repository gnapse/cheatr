require "rest_client"

module Cheatr::Client
  class Sheet

    attr_reader :name, :contents
    attr_reader :errors, :uri, :cache_file

    def self.all(query = nil)
      RestClient.get "http://#{Cheatr::Client.server}/#{query}"
    end

    def initialize(name, opts = {})
      raise "Sheet name '#{name}' is not valid" unless name =~ Cheatr::SHEET_NAME_REGEXP
      @name = name
      @cache_file = File.join(Cheatr::Client.cache_dir, "#{name}.md")
      @uri = "http://#{Cheatr::Client.server}/#{name}"
      fetch(opts)
    end

    #
    # Sets new contents to be saved.
    #
    def contents=(new_contents)
      if new_contents != contents
        @old_contents = contents
        @contents = new_contents
      end
      new_contents
    end

    #
    # Returns true if the contents were last fetched from the remote server,
    # false if fetched from cache.
    #
    def remote?
      @remote == true
    end

    #
    # Returns true if the contents have been modified and need to be saved,
    # false otherwise.
    #
    def changed?
      @old_contents != @contents
    end

    #
    # Saves the contents if changed.
    #
    # Cache is updated if saving to remote server was successful.
    #
    # Returns true if successful, false otherwise.
    #
    def save
      return false if contents.nil?
      if changed? && save_remote
        # Re-fetch because the server may modify contents on saving.
        # Cached version will be saved during re-fetching below.
        fetch(ignore_cache: true)
      end
      !changed?
    end

    #
    # Fetches the contents, either from cache if available, or from the remote
    # server.
    #
    # If ignore_cache is true, the cache is ignored, and contents are updated
    # from the remote server.
    #
    # If contents are fetched from the remote server, the cache is updated.
    # Returns true if successful, false otherwise.
    #
    def fetch(opts = {})
      fetched = opts[:ignore_cache] ? nil : fetch_cache
      fetched ||= fetch_remote
      if fetched
        @contents = fetched
        @old_contents = @contents
        save_cache if remote?
      end
      !!fetched
    end

    private

    #
    # Saves contents to the cache file.
    #
    def save_cache
      File.open(cache_file, 'w') { |f| f.write(contents) } unless contents.nil?
    end

    #
    # Returns the cached contents, or nil.
    #
    def fetch_cache
      @remote = false
      File.read(cache_file) rescue nil
    end

    #
    # Saves the contents to remote server.
    #
    # Returns true if successful, false otherwise.
    #
    def save_remote
      RestClient.put uri, contents
      @errors = nil
      true
    rescue RestClient::BadRequest => e
      @errors = e.response.body.strip.split("\n")
      false
    rescue Errno::ECONNREFUSED => e
      @errors = ["Could not connect to server (#{e.message})"]
      false
    end

    #
    # Fetches contents from remote server.
    #
    # Returns the contents, or nil if unsuccessful.
    #
    def fetch_remote
      @remote = true
      RestClient.get uri
    rescue RestClient::ResourceNotFound
      @errors = ["Sheet '#{name}' does not exist."]
      nil
    rescue Errno::ECONNREFUSED => e
      @errors = ["Could not connect to server (#{e.message})"]
      nil
    end

  end
end
