---
title: About the InSpec DSL
---

# InSpec DSL

The InSpec DSL is a Ruby-based DSL for writing audit controls, which includes audit resources that you can invoke. Core and custom resources are written as regular Ruby classes which inherit from `Inspec.resource`.

Assuming the following JSON file exists on a node and needs to be tested:

    {
      "keys":[
        {"username":"john", "key":"/opt/keys/johnd.key"},
        {"username":"jane", "key":"/opt/keys/janed.key"},
        {"username":"sunny ", "key":"/opt/keys/sunnym.key"}
      ]
    }

The following example shows how to use pure Ruby code (variables, loops, conditionals, regular expressions, etc.) to run a few tests against the above JSON file:

    control 'check-interns' do
      # use the json inspec resource to get the file
      json_obj = json('/opt/keys/interns.json')
      describe json_obj do
        its('keys') { should_not eq nil }
      end
      if json_obj['keys']
        # loop over the keys array
        json_obj['keys'].each do |intern|
          username = intern['username'].strip
          # check for white spaces chars in usernames
          describe username do
            it { should_not match(/\s/) }
          end
          # check key file owners and permissions
          describe file(intern['key']) do
            it { should be_owned_by username }
            its('mode') { should cmp '0600' }
          end
        end
      end
    end


# Custom Audit Resources

InSpec provides a mechanism for defining custom audit resources. These become available with their respective names and provide a simple way to extend functionality in compliance profiles.

## Cookbook Location

Resources may be added to profiles in the `/libraries` directory in a cookbook:

    ...
    ├── libraries
    │   └── gordon_config.rb


## Syntax

A custom audit resource takes the following form:

    class Tiny < Inspec.resource(1)
      name 'tiny'
    end

Custom audit resources are written as a regular Ruby `class` which inherits from `Inspec.resource`. The number (`1`) specifies the version of InSpec this custom audit resource targets. As InSpec evolves, this interface may change and may require a higher version number.


## Properties

A custom audit resource has the following properties:

`name`

Required. The identifier of the custom audit resource.

`desc`

Optional. A description of the custom audit resource.

`example`

Optional. An example usage of the custom audit resource.


## Methods

A custom audit resource has the following methods are available:

`inspec`

Contains a registry of all other resources to interact with the operating system or target in general.

`skip_resource`

A resource may call this method to indicate that requirements aren't met. All tests that use this resource will be marked as `skipped`.


## Example

The following example shows a full resource using attributes and methods to provide simple access to a configuration file:

    class GordonConfig < Inspec.resource(1)
      name 'gordon_config'

      desc '
        Resource description ...
      '

      example '
        describe gordon_config do
          its("signal") { should eq "on" }
        end
      '

      # Load the configuration file on initialization
      def initialize(path = nil)
        @path = path || '/etc/gordon.conf'
        @params = SimpleConfig.new( read_content )
      end

      # Expose all parameters of the configuration file.
      def method_missing(name)
        @params[name]
      end

      private

      def read_content
        f = inspec.file(@path)
        # Test if the path exist and that it's a file
        if f.file?
          # Retrieve the file's contents
          f.content
        else
          # If the file doesn't exist, skip all tests that use gordon_config
          skip_resource "Can't read config from #{@path}."
        end
      end
    end


# Ruby Execution

Ruby code used in custom audit resources and controls is executed on the system that runs InSpec. This allows InSpec to work without requiring Ruby and Ruby gems on a remote target. For example, using `ls` or `system('ls')` will result in the `ls` command being run locally and not on the target(remote) system. In order to process the output of `ls` executed on the target system, use `command('ls')` or `powershell('ls')`.

Similarly, use `file(PATH)` to access files or directories from remote systems in your tests.

# Debug Controls

The following example shows an InSpec control that uses Ruby variables to instantiate an InSpec resource once, and then use that content in multipLe tests:

    control 'check-perl' do
      impact 0.3
      title 'Check perl compiled options and permissions'
      perl_out = command('perl -V')
      #require 'pry'; binding.pry;
      describe perl_out do
        its('exit_status') { should eq 0 }
        its('stdout') { should match (/USE_64_BIT_ALL/) }
        its('stdout') { should match (/useposix=true/) }
        its('stdout') { should match (/-fstack-protector/) }
      end

      # extract an array of include directories
      perl_inc = perl_out.stdout.partition('@INC:').last.strip.split("\n")
      # ensure include directories are only writable by 'owner'
      perl_inc.each do |path|
        describe directory(path.strip) do
          it { should_not be_writable.by('group') }
          it { should_not be_writable.by('other') }
        end
      end
    end


## Use Pry

The previous example comments out the `require 'pry'; binding.pry;` line. Remove the `#` prefix, and then re-run the control. The execution of the control will stop at that line and open a Pry shell from which troubleshooting, printing variables, viewing available methods, etc. may be one. For example:

    [1] pry> perl_out.exit_status
    => 0
    [2] pry> perl_out.stderr
    => ""
    [3] pry> ls perl_out
    Inspec::Plugins::Resource#methods: inspect
    Inspec::Resources::Cmd#methods: command  exist?  exit_status  result  stderr  stdout  to_s
    Inspec::Plugins::ResourceCommon#methods: resource_skipped  skip_resource
    Inspec::Resource::Registry::Command#methods: inspec
    instance variables: @__backend_runner__  @__resource_name__  @command  @result
    [4] pry> perl_out.stdout.partition('@INC:').last.strip.split("\n")
    => ["/Library/Perl/5.18/darwin-thread-multi-2level",
     "    /Library/Perl/5.18",
    ...REDACTED...
    [5] pry> exit    # or abort


## Use Ruby

Since the InSpec shell is Pry based the shell also acts as an interactive Ruby session. Ruby expressions may be written, and then evaluated. To open the shell in a command window:

    $ inspec shell
    Welcome to the interactive InSpec Shell
    To find out how to use it, type: help

and then add Ruby:

    inspec> 1 + 2
    => 3

Type `exit` to exit the shell:

    $ inspec> exit


## Use inspec shell

Use Pry inside both the controls and resources. Similarly, for development and testing, use `inspec shell` which is based on Pry, for example:

    $ inspec shell
    Welcome to the interactive InSpec Shell
    To find out how to use it, type: help

    inspec> command('ls /home/gordon/git/inspec/docs').stdout
    => "ctl_inspec.rst\ndsl_inspec.rst\ndsl_resource.rst\n"
    inspec> command('ls').stdout.split("\n")
    => ["ctl_inspec.rst", "dsl_inspec.rst", "dsl_resource.rst"]

    inspec> help command
    Name: command

    Description:
    Use the command InSpec audit resource to test an arbitrary command that is run on the system.

    Example:
    describe command('ls -al /') do
      it { should exist }
      its('stdout') { should match /bin/ }
      its('stderr') { should eq '' }
      its('exit_status') { should eq 0 }
    end

The InSpec shell will automatically evaluate the result of every command as if it were a test file. Use any InSpec audit resource (and its matchers) in the shell. First open the shell:

    $ inspec shell
    Welcome to the interactive InSpec Shell
    To find out how to use it, type: help

then run some resources:

    inspec> file('/Users/ksubramanian').directory?
    => true
    inspec> os_env('HOME')
    => Environment variable HOME
    inspec> os_env('HOME').content
    => /Users/ksubramanian
    inspec> exit

InSpec tests are executed immediately:

    inspec> describe file('/Users')     # Empty test.
    Summary: 0 successful, 0 failures, 0 skipped
    inspec> describe file('/Users') do  # Test with one check.
    inspec>   it { should exist }
    inspec> end
      ✔  File /Users should exist

    Summary: 1 successful, 0 failures, 0 skipped

All tests in a control are immediately executed as well. If a control is redefined in the shell, the old control's tests are destroyed and replaced with the redefinition and the control is re-run:

    inspec> control 'my_control' do
    inspec>   describe os_env('HOME') do
    inspec>     its('content') { should eq '/Users/ksubramanian' }
    inspec>   end
    inspec> end
      ✔  my_control: Environment variable HOME content should eq "/Users/ksubramanian"

      Summary: 1 successful, 0 failures, 0 skipped

Syntax errors are illegal tests are also detected and reported:

    inspec> control 'foo' do
    inspec>   thisisnonsense
    inspec> end
    NameError: undefined local variable or method 'thisisnonsense' for #<#<Class:0x007fd63b571f98>:0x007fd639825cc8>
    from /usr/local/lib/ruby/gems/2.3.0/gems/rspec-expectations-3.5.0/lib/rspec/matchers.rb:967:in 'method_missing'
    inspec> control 'foo' do
    inspec>   describe file('wut') do
    inspec>     its('thismakesnosense') { should cmp 'fail' }
    inspec>   end
    inspec> end
      ✖  foo: File wut thismakesnosense  (undefined method 'thismakesnosense' for File wut:Inspec::Resource::Registry::File)

      Summary: 0 successful, 1 failures, 0 skipped
