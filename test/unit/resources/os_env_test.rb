# encoding: utf-8
# author: Christoph Hartmann
# author: Dominik Richter

require 'helper'
require 'inspec/resource'

describe 'Inspec::Resources::OsEnv' do
  let(:params) {{
    'PATH' => '/usr/sbin:/usr/bin:/sbin:/bin',
    'LANG' => 'en_US.utf8',
  }}

  it 'verify ntp config parsing' do
    resource = load_resource('os_env', 'PATH')
    _(resource.split).must_equal %w{/usr/sbin /usr/bin /sbin /bin}
  end

  it 'can read all environment variables' do
    resource = load_resource('os_env')
    _(resource.params).must_equal(params)
  end
end
