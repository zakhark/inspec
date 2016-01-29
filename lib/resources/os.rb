# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann

require 'train'
require 'train/extras'

class OS < Inspec.resource(1)
  name 'os'
  desc 'Use the os InSpec audit resource to test the platform on which the system is running.'
  example "
    describe os[:family] do
      it { should eq 'redhat' }
    end
  "

  # reuse helper methods from backend
  Train::Extras::OSCommon::OS.keys.each do |os_family|
    m = (os_family + '?').to_sym
    define_method(m) do
      inspec.backend.os.method(m).call
    end
  end

  def [](name)
    # convert string to symbol
    name = name.to_sym if name.is_a? String
    inspec.backend.os[name]
  end

  def to_s
    'Operating System Detection'
  end
end
