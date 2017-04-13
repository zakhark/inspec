# encoding: utf-8
# author: Guilhem Lettron

require 'helper'
require 'inspec/resource'

describe 'Inspec::Resources::FaradayResource' do
  it 'verify simple http' do
    stub_request(:get, "www.example.com").to_return(status: 200, body: 'pong')

    resource = load_resource('faraday', url: 'http://www.example.com')
    response = resource.get
    _(response.status).must_equal 200
    _(response.body).must_equal 'pong'
  end

  it 'verify http with basic auth' do
    stub_request(:get, "www.example.com").with(basic_auth: ['user', 'pass']).to_return(status: 200, body: 'auth ok')
    resource = load_resource('faraday', url: 'http://www.example.com', auth: { user: 'user', pass: 'pass'})
    _(resource.status).must_equal 200
    _(resource.body).must_equal 'auth ok'
  end
end
