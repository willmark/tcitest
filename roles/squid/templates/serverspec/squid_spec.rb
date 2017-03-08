require 'spec_helper'

describe package('squid') do
  it { should be_installed.by('apt') }	#SQD001
end

describe file('/etc/squid3/squid.conf') do
  it { should be_file }	#SQD002
end

describe file('/usr/sbin/squid3') do
  it { should be_file }	#SQD003
end

describe file('{{ squid.cache_dir.path }}') do
  it { should be_mode 755 }	#SQD004
  it { should be_owned_by 'proxy' }	#SQD005
  it { should be_grouped_into 'proxy' }	#SQD006
  it { should be_directory }	#SQD007
end

describe file('/etc/squid3/allowed-networks-src.acl') do
  it { should be_file }	#SQD008
end

describe file('/etc/squid3/allowed-domains-dst.acl') do
  it { should be_file }	#SQD009
end

describe file('/etc/squid3/pkg-blacklist-regexp.acl') do
  it { should be_file }	#SQD010
end

describe port('{{ squid.port }}') do
  it { should be_listening }	#SQD011
end

describe service('squid3') do
  it { should be_enabled }
end

