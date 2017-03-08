# {{ ansible_managed }}

require 'spec_helper'

describe package('logstash-forwarder') do
  it { should be_installed }
end

describe service('logstash-forwarder') do
  it { should be_enabled }
end
