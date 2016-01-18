# encoding: utf-8
# author: Stephan Renatus

require 'helper'
require 'inspec/cli'
#require 'json'

describe 'inspec detect' do
  it 'outputs JSON by default' do
    out = capture_io { Inspec::CLI.new.detect }
    out.must_match /^$/ # testing, this should fail
  end
end
