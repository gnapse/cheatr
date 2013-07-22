require 'erb'
require 'redcarpet'
require 'sinatra/base'
require 'cheatr/server/sheet'
require 'cheatr/server/helpers'

module Cheatr::Server
  class App < Sinatra::Base
    include Helpers

    # Routes

    get '/' do
      @title = 'Cheat sheets'
      @sheets = Sheet.all
      template :index
    end

    get '/:name' do |name|
      if query? name
        @sheets = Sheet.all(name)
        @title = "Cheat sheets matching '#{name}'"
        template :index
      else
        @sheet = Sheet.find!(name)
        @title = @sheet.human_name
        template :sheet
      end
    end

    put '/:name' do |name|
      @sheet = Sheet.new(name)
      @sheet.contents = request.body.read
      if @sheet.save
        text "Sheet #{name} updated successfully"
      else
        text @sheet.errors.full_messages, status: 400
      end
    end

    # Configuration

    def self.base_path(append = nil)
      append ? File.join(path, append) : path
    end

    configure do
      set :app_file, __FILE__
      set :base_path, File.dirname(__FILE__)
      set :views, File.join(settings.base_path, 'views')
      set :public_folder, File.join(settings.base_path, 'public')
      Cheatr::Server.config.each_pair do |option, value|
        set option.to_sym, value
      end
    end

    configure :production, :development do
      enable :logging
    end

    configure :development do
      enable :logging, :dump_errors, :raise_errors
    end

    configure :production do
      set :raise_errors, false
      set :show_exceptions, false
    end

    error do
      status 500
      template :error
    end

    not_found do
      send_file File.join(settings.public_folder, '404.html'), status: 404
    end

  end
end
