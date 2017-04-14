# encoding: utf-8
# copyright: 2017, Criteo
# copyright: 2017, Chef Software Inc
# author: Guilhem Lettron, Christoph Hartmann
# license: Apache v2

require 'faraday'
require 'hashie'

module Inspec::Resources
  class FaradayResource < Inspec.resource(1)
    # include forwardable

    name 'faraday'
    desc 'Use the faraday InSpec audit resource to test HTTP endpoints'
    example """
      describe faraday('http://sushi.com').get do
        its('body') { should cmp 'Spicy Crab' }
      end

      describe faraday('http://sushi.com', params: {page: 1}).get do
        its('body') { should cmp 'Spicy Crab' }
      end

      describe faraday(url: 'http://sushi.com', params: {page: 1}).get do
        its('body') { should cmp 'Spicy Crab' }
      end

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
    def initialize(url=nil, params={})
      # @init_args = init_args
      @url = url
      @params = params
    end

    # def_delegate connection, :get, :post, #...

    def get
      connection.get
    end

    def status
      response.status
    end

    def body
      response.body
    end

    private

    def connection
      @conn ||= Faraday.new(@url, @params) # do |conn|
      #   conn.basic_auth :foo, :Bar
      # end
      # @conn.basic_auth(@auth[:user], @auth[:pass]) unless @auth.empty?
      # @conn
    end

    def response
      @response = connection.send('get') do |req|
        req.body = {}
      end
    end
  end
end
