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

  describe 'when reading a specific environment param' do
    let(:resource) { load_resource('os_env', 'PATH') }

    it 'splits contents of $PATH' do
      _(resource.split).must_equal %w{/usr/sbin /usr/bin /sbin /bin}
    end

    it 'retrieves the raw content' do
      _(resource.content).must_equal params['PATH']
    end
  end

  describe 'when reading all environment params' do
    let(:resource) { load_resource('os_env') }

    it 'can read all environment variables' do
      _(resource.params).must_equal(params)
    end

    it 'can read all environment variables' do
      _(resource.content).must_be_nil
    end
  end

end
