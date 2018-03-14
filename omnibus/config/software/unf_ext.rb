# encoding: utf-8

name 'unf_ext'

dependency 'ruby'
dependency 'rubygems'
dependency 'bundler'
dependency 'appbundler'

license :project_license

default_version "0.0.7.6"

build do
  # override for unf_ext until
  # https://github.com/knu/ruby-unf_ext/pull/39
  # is merged and released
  gem 'unf_ext', '=0.0.7.6', :git => 'https://github.com/jquick/ruby-unf_ext.git'
end
