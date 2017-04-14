# encoding: utf-8
# author: Guilhem Lettron

require 'helper'
require 'inspec/resource'

describe 'Inspec::Resources::FaradayResource' do

  # describe faraday(url: 'http://sushi.com', params: {page: 1}).get do
  #   its('body') { should cmp 'Spicy Crab' }
  # end

  it 'verify simple http' do
    stub_request(:get, "http://sushi.com").to_return(status: 200, body: 'Spicy Crab')
    resource = load_resource('faraday', 'http://sushi.com')
    response = resource.get
    _(response.status).must_equal 200
    _(response.body).must_equal 'Spicy Crab'
  end

  it 'verify simple http' do
    stub_request(:get, "http://sushi.com").with(query: {page: 1}).to_return(status: 200, body: 'Spicy Crab')
    resource = load_resource('faraday', 'http://sushi.com', params: {page: 1})
    response = resource.get
    _(response.status).must_equal 200
    _(response.body).must_equal 'Spicy Crab'
  end

  it 'verify simple http' do
    stub_request(:get, "http://sushi.com").with(query: {page: 1}).to_return(status: 200, body: 'Spicy Crab')
    resource = load_resource('faraday', url: 'http://sushi.com', params: {page: 1})
    response = resource.get
    _(response.status).must_equal 200
    _(response.body).must_equal 'Spicy Crab'
  end

  # it 'verify http with basic auth' do
  #   stub_request(:get, "www.example.com").with(basic_auth: ['user', 'pass']).to_return(status: 200, body: 'auth ok')
  #   resource = load_resource('faraday', 'http://www.example.com', { user: 'user', pass: 'pass'})
  #   _(resource.status).must_equal 200
  #   _(resource.body).must_equal 'auth ok'
  # end
end
