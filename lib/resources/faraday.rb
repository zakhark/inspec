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
    desc 'Use the faraday InSpec audit resource to test HTTP endpoints'
    example """
      describe faraday(:url => 'http://sushi.com').get '/nigiri/sake.json' do
        its('body') { should cmp 'pong' }
      end

      describe faraday(:url => 'https://sushi.com', :ssl => {:verify => false}).get '/nigiri', { name: 'Maguro' }
        its('status') { should cmp 'pong' }
        its('body') { should cmp 'pong' }
      end

      describe faraday(:url => 'http://sushi.com').post {url: '/nigiri', headers: { 'Content-Type' => 'application/json' }, body: \"{ 'name': 'Unagi' }\" }
        its('body.name') { should eq 'Unagi' }
      end

      describe faraday(:url => 'http://sushi.com') do |conn|

      end do

      end
    """

    # rubocop:disable ParameterLists
    def initialize(init_args)
      @init_args = init_args
    end

    def get
      connection.get
    end

    def status
      connection.status
    end

    private

    def connection
      puts('!' * 100)
      # puts(@auth)
      conn = Faraday.new(**@init_args)
      # conn.basic_auth(@auth[:user], @auth[:pass]) unless @auth.empty?
      conn
    end
  end
end
