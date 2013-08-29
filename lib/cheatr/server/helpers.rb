module Cheatr::Server
  module Helpers
    def query?(name)
      name.include? '*'
    end

    def html?
      request.accept? 'text/html'
    end

    def default_content_type
      html? ? 'text/html' : 'text/markdown'
    end

    #
    # Processes the given text as markdown, additionally processing cheatr links as well.
    #
    def md(text)
      markdown text
        .gsub(/{{([a-z]+([\.\-\_][a-z]+)*)}}/, '[\1](/\1)')             # {{name}}           -> [name](/name)
        .gsub(/{{([^\|}]+)\|([a-z]+([\.\-\_][a-z]+)*)}}/, '[\1](/\2)')  # {{link text|name}} -> [link text](/name)
        .to_s
    end

    def text(output, opts = {})
      content_type 'text/plain'
      status opts[:status] if opts[:status]
      if output.is_a?(Array)
        output = output.map { |s| "#{s}\n" }
      end
      logger.info output
      output
    end

    def template(name, opts = {})
      status opts[:status] if opts[:status]
      content_type opts[:content_type] || default_content_type
      logger.info "Rendering template #{name}"
      output = erb :"#{name}.md", layout: false
      if html?
        erb md(output), layout: "layout.html".to_sym
      else
        output
      end
    end
  end
end
