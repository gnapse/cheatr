
module Cheatr
  module Server
    autoload :Sheet, "cheatr/server/sheet"
    autoload :App, "cheatr/server/app"

    def self.run(repository, opts = {})
      @@config = @@config.merge(opts.to_hash)
      Sheet.repository = File.expand_path(repository)
      puts "Serving cheatr repository at #{Sheet.repository}"
      App.run!
    rescue Cheatr::Error => e
      puts "Error: #{e.message}"
    end

    @@config = {}

    def self.config
      @@config
    end
  end
end
