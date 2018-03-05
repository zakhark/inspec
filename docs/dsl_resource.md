---
title: Resource Authoring Guide
---

# Resource Authoring Guide

InSpec provides a mechanism for defining custom resources. These become
available with their respective names and provide an easy way to provide new functionality to
profiles.

You may choose to distribute your custom resources as a `resource pack` (a special form of an InSpec profile that contains only resources but no controls). Alternatively, you may be developing resources that you would like to contribute to the InSpec project itself (a `core resource`). The syntax and general guidelines are the same for either approach, but there are some differences in file locations and expectations of code quality.

This document will first explore writing a resource to be distributed in a resource pack, then expand into important considerations when writing for a broader audience, such as a resource you'd like to contribute to InSpec core.

## File Structure of a Resource Pack

This is the smallest possible resource pack, containing one custom resource (`signal_lamp_config`).

```bash
$ tree examples/profile
examples/profile
├── libraries
│   └── signal_lamp_config.rb
│── inspec.yml
```

The inspec.yml file is minimal, containing only the name of the profile / resource pack:

```yaml
name: vigilante_notification
```

 A more realistic resource pack would include some other files - mostly related to testing - which we will build up and discuss later.


## Resource structure

The smallest possible resource file takes this form:

```ruby
class SignalLampConfig < Inspec.resource(1)
  name 'signal_lamp_config'
end
```

Resources are written as a regular Ruby class which inherits from
`Inspec.resource`. The number (1) specifies the version this resource
plugin targets. As InSpec evolves, this interface may change and may
require a higher version.

The following attributes can be configured:

* name - Identifier of the resource (required)
* desc - Description of the resource (optional)
* example - Example usage of the resource (optional)

The following methods are available to the resource:

* inspec - A reference to the `Inspec::Runner` object, which provides context. For example, it contains a registry of resources which you may use to interact with the operating system or target in general.
* skip\_resource - A resource may call this method to indicate that requirements aren't met. All tests that use this resource will be marked as skipped.

The following example shows a full resource to provide simple access to a configuration file.  It allows you to specify the path to the configuraion file, and then exposes one matcher (`be_illuminated`) and one property (`color`).

```ruby
class SignalLampConfig < Inspec.resource(1)
  name 'signal_lamp_config'

  desc '
    Examines the configuration file of the Chiroptera Signal.
  '

  example '
    describe signal_lamp_config do
      it { should be_illuminated }
      its("color") { should be "yellow" }
    end
  '

  # Load the configuration file on initialization
  def initialize(path = nil)
    @path = path || '/etc/signal_lamp.conf'
    # SimpleConfig is a InSpec helper class, often used 
    # to read INI-style or `key = value ` configuration files
    @config_contents = SimpleConfig.new( read_content )
  end

  # Expose the property, 'color'.
  def color
    @config_contents['color']
  end

  # Expose a matcher, be_illuminated.  Anything ending in '?' 
  # will be treated as a matcher, and will have 'be_' prefixed.
  def illuminated?
    @config_contents['status'] == 'on'
  end

  private

  def read_content
    # Keep in mind the file is on the remote machine being tested, not 
    # on the local machine running InSpec. This re-uses an existing 
    # InSpec resource, `file`, to read the config file's contents.
    f = inspec.file(@path)
    # Test if the path exists and that it's a file
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
