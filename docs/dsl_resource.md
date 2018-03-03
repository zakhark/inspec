---
title: Resource Authoring Guide
---

# Resource Authoring Guide

InSpec provides a mechanism for defining custom resources. These become
available with their respective names and provide easy functionality to
profiles.

You may choose to distribute your custom resources as a `resource pack` (a special form of an InSpec profile that contains only resources but no controls). Alternatively, you may be developing resources that you would like to contribute to the InSpec project itself (a `core resource`). The syntax and general guidelines are the same for either approach, but there are some differences in file locations and expectations of code quality.

This document will first explore writing a resource to be distributed in a resource pack, then expand into important considerations when writing for a broader audience, such as a resource you'd like to contribute to InSpec core.

## Motivation

Suppose that we work for the local police commisioner, and are responsible for verifying the configuration of a roof-mounted spotlight signal.

## File Structure of a Resource Pack

This is the smallest possible resource pack, containing one custom resource (`gordon_config`).

```bash
$ tree examples/profile
examples/profile
├── libraries
│   └── gordon_config.rb
│── inspec.yml
```

The inspec.yml file is minimal, containing only the name of the profile / resource pack:

```yaml
name: bat-related-signalling
```

 A more realistic resource pack would include some other files - mostly related to testing - which we will build up and discuss later.


## Resource structure

The smallest possible resource takes this form:

```ruby
class Tiny < Inspec.resource(1)
  name 'tiny'
end
```

Resources are written as a regular Ruby class which inherits from
Inspec.resource. The number (1) specifies the version this resource
plugin targets. As InSpec evolves, this interface may change and may
require a higher version.

The following attributes can be configured:

* name - Identifier of the resource (required)
* desc - Description of the resource (optional)
* example - Example usage of the resource (optional)

The following methods are available to the resource:

* inspec - Contains a registry of all other resources to interact with the operating system or target in general.
* skip\_resource - A resource may call this method to indicate that requirements aren't met. All tests that use this resource will be marked as skipped.

The following example shows a full resource using attributes and methods
to provide simple access to a configuration file:

```ruby
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
```

For a full example, see our [example resource](https://github.com/chef/inspec/blob/master/examples/profile/libraries/gordon_config.rb).
