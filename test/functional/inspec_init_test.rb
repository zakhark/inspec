require 'functional/helper'

describe 'inspec init' do
  include FunctionalHelper

  describe 'inspec init profile with/slash' do
    it 'prevents profile names without valid characters' do
      out = inspec('init profile with//slash')
      out.exit_status.must_equal 1
      out.stderr.must_match(%r{^The})
    end

    it 'allows profile names with valid characters' do
      out = inspec('init profile withoutslash')
      out.exit_status.must_equal 0
    end

    it 'allows profile names with hypens' do
      out = inspec('init profile with-hyphen')
      out.exit_status.must_equal 0
    end

    it 'allows profile names with periods' do
      out = inspec('init profile with.period')
      out.exit_status.must_equal 0
    end

    it 'allows profile names with valid characters' do
      out = inspec('init profile with_underscore')
      out.exit_status.must_equal 0
    end
  end
end
