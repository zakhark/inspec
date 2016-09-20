---
title: About InSpec
---

# InSpec

InSpec is an open-source run-time framework and rule language used to specify compliance, security, and policy requirements for testing any node in your infrastructure.

* The project name refers to "infrastructure specification"
* InSpec includes a collection of resources to help you write auditing rules quickly and easily using the Compliance DSL
* Use InSpec to examine any node in your infrastructure; run the tests locally or remotely
* Any detected security, compliance, or policy issues are flagged in a log
* The InSpec audit resource framework is fully compatible with Chef Compliance

# Examples

The following examples show how to build tests.

## Only accept requests on secure ports

This code uses the `port` resource to ensure that a web server is only listening on well-secured ports.

    describe port(80) do
      it { should_not be_listening }
    end

    describe port(443) do
      it { should be_listening }
      its('protocols') {should eq ['tcp']}
    end

## Use approved strong ciphers

This code uses the `sshd_config` resource to ensure that only enterprise-compliant ciphers are used for SSH servers.

    describe sshd_config do
      its('Ciphers') { should cmp('chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr') }
    end

##Test a kitchen.yml file driver

This code uses the `yaml` resource to ensure that the Kitchen driver is Vagrant.

    describe yaml('.kitchen.yaml') do
      its('driver.name') { should eq('vagrant') }
    end
