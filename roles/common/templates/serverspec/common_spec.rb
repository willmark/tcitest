# {{ ansible_managed }}

require 'spec_helper'
require 'etc'

describe file('/etc/timezone') do
  it { should be_file } #OPS002
  it { should contain 'Etc/UTC' } #OPS003
end

describe file('/etc/sudoers') do
  its(:content) { should match /^Defaults\s+env_keep\+=SSH_AUTH_SOCK/ } #OPS014
end

describe service('ssh') do
  it { should be_enabled }
end

describe file('/etc/ssh/sshd_config') do
  its(:content) { should match /^PasswordAuthentication no/ } #OPS015
  its(:content) { should_not match /^PasswordAuthentication yes/ } #OPS016
  its(:content) { should match /^PermitRootLogin no/ } #OPS017
  its(:content) { should_not match /^PermitRootLogin yes/ } #OPS018
  its(:content) { should match /^PermitEmptyPasswords no/ } #OPS019
  its(:content) { should_not match /^PermitEmptyPasswords yes/ } #OPS020
  its(:content) { should match /^PubkeyAuthentication yes/ } #OPS021
  its(:content) { should_not match /^PubkeyAuthentication no/ } #OPS022
  its(:content) { should match /^RSAAuthentication yes/ } #OPS023
  its(:content) { should_not match /^RSAAuthentication no/ } #OPS024
  its(:content) { should match /^HostbasedAuthentication no/ } #OPS025
  its(:content) { should_not match /^HostbasedAuthentication yes/ } #OPS026
  its(:content) { should match /^IgnoreRhosts yes/ } #OPS027
  its(:content) { should_not match /^IgnoreRhosts no/ } #OPS028
  its(:content) { should match /^PrintMotd yes/ } #OPS029
  its(:content) { should_not match /^PrintMotd no/ } #OPS030
  its(:content) { should match /^PermitUserEnvironment no/ } #OPS031
  its(:content) { should_not match /^PermitUserEnvironment yes/ } #OPS032
  its(:content) { should match /^StrictModes yes/ } #OPS033
  its(:content) { should_not match /^StrictModes no/ } #OPS034
  its(:content) { should match /^ServerKeyBits 1024/ } #OPS035
  its(:content) { should match /^TCPKeepAlive yes/ } #OPS036
  its(:content) { should_not match /^TCPKeepAlive no/ } #OPS037
  its(:content) { should match /^LoginGraceTime 120/ } #OPS038
  its(:content) { should match /^MaxStartups 100/ } #OPS039
  its(:content) { should match /^LogLevel INFO/ } #OPS040
  its(:content) { should match /^MaxAuthTries 5/ } #OPS041
  its(:content) { should match /^KeyRegenerationInterval 3600/ } #OPS042
  its(:content) { should match /^Protocol 2/ } #OPS043
  its(:content) { should match /^GatewayPorts no/ } #OPS044
  its(:content) { should_not match /^GatewayPorts yes/ } #OPS045
  its(:content) { should match /^UsePAM yes/ } #OPS046
  its(:content) { should_not match /^UsePAM no/ } #OPS047
  its(:content) { should match /^Ciphers aes128-ctr,aes192-ctr,aes256-ctr/ } #OPS092
  its(:content) { should match /^MACs hmac-sha2-256,hmac-sha2-512,hmac-sha1,hmac-ripemd160/ } #OPS093
{% if common.ssh.disable_dns|bool %}
  its(:content) { should match /^UseDNS no/ } #OPS048
  its(:content) { should_not match /^UseDNS yes/ } #OPS049
{% else %}
  its(:content) { should match /^UseDNS yes/ } #OPS050
  its(:content) { should_not match /^UseDNS no/ } #OPS051
{% endif %}
end

describe package('ufw') do
  it { should be_installed } #OPS056
end

describe command('ufw status') do
  its(:stdout) { should match /Status: active/ } #OPS057
end

describe file('/etc/pam.d/login') do
  its(:content) { should contain /^@include common-auth/ } #OPS062
  its(:content) { should contain /^@include common-account/ } #OPS063
  its(:content) { should contain /^@include common-session/ } #OPS064
  its(:content) { should contain /^@include common-password/ } #OPS065
end

describe file('/etc/pam.d/common-password') do
  its(:content) { should contain /^password \[success=1 default=ignore\] pam_unix.so obscure use_authtok sha512 remember=7 shadow/ } #OPS066
end

describe file('/etc/adduser.conf') do
  its(:content) { should match /^DIR_MODE=[0-7][0-5][0-5]/ } #OPS067
end

files = ['.rhosts','.netrc']
files.each do |file|
  describe file ("~root/#{file}") do
    it { should_not exist } #OPS068
  end
end

files = ['bin', 'boot', 'dev', 'etc', 'home','lib',
         'lib64', 'lost+found', 'media', 'mnt', 'opt', 'proc', 'root',
         'run', 'sbin', 'srv', 'sys', 'usr', 'var']
files.each do |file|
  describe file("/#{file}/") do
    it { should be_directory } #OPS069
    it { should be_mode '[0-7][0-7][0-5]' } #OPS070
  end
end

files = ['bin', 'games', 'include', 'lib', 'local', 'sbin', 'share', 'src']
files.each do |file|
  describe file("/usr/#{file}/") do
    it { should be_directory } #OPS071
    it { should be_mode '[0-7][0-7][0-5]' } #OPS072
  end
end

describe file('/etc/security/opasswd') do
  it { should exist } #OPS073
  it { should be_mode 600 }     #OPS074
end

describe file('/etc/shadow') do
  it { should exist } #OPS075
  it { should be_mode 600 } #OPS076
end

files = ['backups', 'cache', 'lib', 'local',
         'log', 'mail', 'opt', 'spool']
files.each do |file|
  describe file("/var/#{file}/") do
    it { should be_directory } #OPS077
    it { should be_mode '[0-2]*[0-7][0-7][0-5]' } #OPS078
  end
end

describe file('/var/tmp/') do
  it { should be_directory } #OPS079
end

files = ['syslog', 'auth.log']
files.each do |file|
  describe file ("/var/log/#{file}") do
    it { should exist } #OPS080
    it { should be_mode '[0-7][0-5][0-5]' } #OPS081
    it { should be_owned_by 'syslog' }  #OPS082
  end
end

describe file('/tmp/') do
  it { should be_directory } #OPS083
end

files = ['/etc/init/', '/var/spool/cron/', '/etc/cron.d/', '/etc/init.d/', '/etc/rc0.d/',
         '/etc/rc1.d/', '/etc/rc2.d/','/etc/rc3.d/','/etc/rc4.d/','/etc/rc5.d/','/etc/rc6.d/','/etc/rcS.d/']
files.each do |file|
  describe file("#{file}") do
    it { should be_mode '[0-7][0-7][0-5]' } #OPS084
  end
end

files = ['/', '/usr', '/etc', '/etc/security/opasswd',
         '/etc/shadow', '/var', '/var/tmp', '/var/log',
         '/var/log/wtmp', '/tmp']
files.each do |file|
  describe file(file) do
    it { should be_owned_by 'root' } #OPS085
  end
end
