# encoding: utf-8
# copyright: 2015, Vulcano Security GmbH

require 'utils/simpleconfig'
require 'utils/file_reader'

module Inspec::Resources
  class SshConf < Inspec.resource(1)
    name 'ssh_config'
    supports platform: 'unix'
    desc 'Use the `ssh_config` InSpec audit resource to test OpenSSH client configuration data located at `/etc/ssh/ssh_config` on Linux and Unix platforms.'
    example "
      describe ssh_config do
        its('cipher') { should contain '3des' }
        its('port') { should eq '22' }
        its('hostname') { should include('example.com') }
      end
    "

    include FileReader

    DEFAULT_UNIX_PATH = '/etc/ssh/ssh_config'.freeze

    def initialize(conf_path = DEFAULT_UNIX_PATH, type = get_type(conf_path))
      @type   = type
      @params = get_params(read_file_content(conf_path))
    end

    def params(*opts)
      opts.inject(@params) do |res, nxt|
        res.respond_to?(:key) ? res[nxt] : nil
      end
    end

    def method_missing(name)
      param = @params[name.to_s.downcase]

      case
      when param.nil?
        param
      when param.length == 1
        param[0]
      else
        param
      end
    end

    def to_s
      'SSH Configuration'
    end

    private

    def get_type(conf_path)
      "SSH #{get_typename(conf_path)} configuration #{conf_path}"
    end

    def get_typename(conf_path)
      conf_path.include?('sshd') ? 'Server' : 'Client'
    end

    def get_params(content)
      return @params = {} if content.empty?

      params = get_params_from_config(content)

      params.keys.map(&:downcase).zip(params.values).to_h
    end

    def get_params_from_config(content)
      SimpleConfig.new(
        content,
        assignment_regex: /^\s*(\S+?)\s+(.*?)\s*$/,
        multiple_values: true,
      ).params
    end
  end

  class SshdConf < SshConf
    name 'sshd_config'
    supports platform: 'unix'
    desc 'Use the sshd_config InSpec audit resource to test configuration data for the Open SSH daemon located at /etc/ssh/sshd_config on Linux and UNIX platforms. sshd---the Open SSH daemon---listens on dedicated ports, starts a daemon for each incoming connection, and then handles encryption, authentication, key exchanges, command execution, and data exchanges.'
    example "
      describe sshd_config do
        its('Protocol') { should eq '2' }
      end
    "

    DEFAULT_UNIX_PATH = '/etc/ssh/sshd_config'.freeze

    def initialize(path = DEFAULT_UNIX_PATH)
      super(path)
    end

    def to_s
      'SSHD Configuration'
    end
  end
end
