# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann

require 'utils/nginx_parser'

module Inspec::Resources
  class NginxConf < Inspec.resource(1)
    name 'nginx_conf'
    desc 'Use the nginx_conf InSpec resource to test configuration data '\
         'for the NginX web server located in /etc/nginx/nginx.conf on '\
         'Linux and UNIX platforms.'
    example "
      describe nginx_conf.params ...
      describe nginx_conf('/path/to/my/nginx.conf').params ...
    "

    def initialize(conf_path = nil)
      @conf_path = conf_path || '/etc/nginx/nginx.conf'
    end

    def params(*opts)
      opts.inject(read_params) do |res, nxt|
        res.respond_to?(:key) ? res[nxt] : nil
      end
    end

    def to_s
      "nginx_conf #{@conf_path}"
    end

    private

    def read_content
      return @content if defined?(@content)
      file = inspec.file(@conf_path)
      if !file.file?
        return skip_resource "Can't find file \"#{@conf_path}\""
      end

      @content = file.content
    end

    def read_params
      return @params if defined?(@params)
      return @params = {} if read_content.nil?
      @params = NginxConfig.parse(read_content)
    rescue Parslet::ParseFailed
      raise "Cannot parse NginX config: \"#{read_content}\""
    end
  end
end
