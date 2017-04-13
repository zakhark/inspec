# encoding: utf-8
# copyright: 2017, Criteo
# copyright: 2017, Chef Software Inc
# author: Guilhem Lettron, Christoph Hartmann
# license: Apache v2

require 'faraday'
require 'hashie'

module Inspec::Resources
  class FaradayResource < Inspec.resource(1)
    name 'faraday'
    desc 'Use the faraday InSpec audit resource to test .......'
    example "
      describe faraday('http://localhost:8080/ping', auth: {user: 'user', pass: 'test'}, params: {format: 'html'}) do
        its('status') { should cmp 200 }
        its('body') { should cmp 'pong' }
        its('headers.Content-Type') { should cmp 'text/html' }
      end

      describe faraday('http://example.com/ping').headers do
        its('Content-Length') { should cmp 258 }
        its('Content-Type') { should cmp 'text/html; charset=UTF-8' }
      end
    "

    # rubocop:disable ParameterLists
    def initialize(url, auth = {})
      @url = url
      @auth = auth
    end

    def get
      response.get
    end

    def status
      response.status
    end

    private

    def response
      puts('!' * 100)
      puts(@auth)
      conn = Faraday.new(@url)
      conn.basic_auth(@auth[:user], @auth[:pass]) unless @auth.empty?
      conn
    end
  end
end
