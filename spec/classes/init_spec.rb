require 'spec_helper'
describe 'nfsclient' do
#it { pp catalogue.resources } # used to determine the generated md5 for the file name in citrix_unix::application

  platform_facts = {
    'RedHat 6' => {
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '6.3',
    },
    'RedHat 7' => {
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '7.3',
    },
    'RedHat 8' => {
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '8.0',
    },
    'Suse 11' => {
      :osfamily               => 'Suse',
      :operatingsystemrelease => '11.3',
      :lsbmajdistrelease      => '11', # rpcbind
    },
    'Suse 12' => {
      :osfamily               => 'Suse',
      :operatingsystemrelease => '12.3',
      :lsbmajdistrelease      => '12', # rpcbind
    },
    'Ubuntu 16.04' => {
      :osfamily               => 'Debian',
      :operatingsystemrelease => '16.04',
      :operatingsystem        => 'Ubuntu',
      :lsbdistid              => 'Ubuntu', # rpcbind
      :lsbdistrelease         => '16.04',  # rpcbind
    },
    'Ubuntu 18.04' => {
      :osfamily               => 'Debian',
      :operatingsystemrelease => '18.04',
      :operatingsystem        => 'Ubuntu',
      :lsbdistid              => 'Ubuntu', # rpcbind
      :lsbdistrelease         => '18.04',  # rpcbind
    },
  }

  describe 'with defaults for all parameters on RedHat 6' do
    let(:facts) { platform_facts['RedHat 6'] }
    it { should compile.with_all_deps }
    it { should contain_class('nfsclient') }
    it { should contain_class('nfs::idmap') }
  end

  describe 'with defaults for all parameters on RedHat 7' do
    let(:facts) { platform_facts['RedHat 7'] }
    it { should compile.with_all_deps }
    it { should contain_class('nfsclient') }
    it { should contain_class('nfs::idmap') }
  end

  describe 'with defaults for all parameters on RedHat 8' do
    let(:facts) { platform_facts['RedHat 8'] }
    it { should compile.with_all_deps }
    it { should contain_class('nfsclient') }
    it { should contain_class('nfs::idmap') }
  end

  describe 'with defaults for all parameters on Suse 11' do
    let(:facts) { platform_facts['Suse 11'] }
    it { should compile.with_all_deps }
    it { should contain_class('nfsclient') }
  end

  describe 'with defaults for all parameters on Suse 12' do
    let(:facts) { platform_facts['Suse 12'] }
    it { should compile.with_all_deps }
    it { should contain_class('nfsclient') }
  end

  describe 'with defaults for all parameters on Ubuntu 16.04' do
    let(:facts) { platform_facts['Ubuntu 16.04'] }
    it { should compile.with_all_deps }
    it { should contain_class('nfsclient') }
  end

  describe 'with defaults for all parameters on Ubuntu 18.04' do
    let(:facts) { platform_facts['Ubuntu 18.04'] }
    it { should compile.with_all_deps }
    it { should contain_class('nfsclient') }
  end

  describe 'with gss set to valid boolean true on RedHat 6' do
    let(:facts) { platform_facts['RedHat 6'] }
    let(:params) { { :gss => true } }

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'    => '/etc/sysconfig/nfs',
        'line'    => 'SECURE_NFS="yes"',
        'match'   => '^SECURE_NFS=.*',
        'notify'  => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('rpcgssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => 'Service[idmapd_service]',
        'provider'  => nil,
      })
    end
    # </OS independent resources>
  end

  describe 'with gss set to valid boolean true on RedHat 7' do
    let(:facts) { platform_facts['RedHat 7'] }
    let(:params) { { :gss => true } }

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'    => '/etc/sysconfig/nfs',
        'line'    => 'SECURE_NFS="yes"',
        'match'   => '^SECURE_NFS=.*',
        'notify'  => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('rpc-gssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => 'Service[idmapd_service]',
        'provider'  => nil,
      })
    end
    # </OS independent resources>
  end

  describe 'with gss set to valid boolean true on RedHat 8' do
    let(:facts) { platform_facts['RedHat 8'] }
    let(:params) { { :gss => true } }

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it { should_not contain_file_line('NFS_SECURITY_GSS') }

    it do
      should contain_service('gss_service').with({
        'ensure' => 'running',
        'enable' => 'true',
        'name'   => 'auth-rpcgss-module.service',
      })
    end

    it do
      should contain_service('rpc-gssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'Service[gss_service]',
        'require'   => 'Service[idmapd_service]',
        'provider'  => nil,
      })
    end
    # </OS independent resources>
  end

  describe 'with gss set to valid boolean true on Suse 11' do
    let(:facts) { platform_facts['Suse 11'] }
    let(:params) { { :gss => true } }


    # <Suse 11 specific resources>
    it do
      should contain_file_line('NFS_START_SERVICES').with({
        'match'   => '^NFS_START_SERVICES=',
        'path'    => '/etc/sysconfig/nfs',
        'line'    => 'NFS_START_SERVICES="yes"',
        'notify'  => [ 'Service[nfs]', 'Service[rpcbind_service]' ]
      })
    end

    it do
      should contain_file_line('MODULES_LOADED_ON_BOOT').with({
        'match'   => '^MODULES_LOADED_ON_BOOT=',
        'path'    => '/etc/sysconfig/kernel',
        'line'    => 'MODULES_LOADED_ON_BOOT="rpcsec_gss_krb5"',
        'notify'  => 'Exec[gss-module-modprobe]',
      })
    end

    it do
      should contain_exec('gss-module-modprobe').with({
        'command'     => 'modprobe rpcsec_gss_krb5',
        'unless'      => 'lsmod | egrep "^rpcsec_gss_krb5"',
        'path'        => '/sbin:/usr/bin',
        'refreshonly' => true,
      })
    end
    # </Suse 11 specific resources>

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'    => '/etc/sysconfig/nfs',
        'line'    => 'NFS_SECURITY_GSS="yes"',
        'match'   => '^NFS_SECURITY_GSS=.*',
        'notify'  => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('nfs').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => nil,
        'provider'  => nil,
      })
    end
    # <OS independent resources>
  end

  describe 'with gss set to valid boolean true on Suse 12' do
    let(:facts) { platform_facts['Suse 12'] }
    let(:params) { { :gss => true } }

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'    => '/etc/sysconfig/nfs',
        'line'    => 'NFS_SECURITY_GSS="yes"',
        'match'   => '^NFS_SECURITY_GSS=.*',
        'notify'  => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('rpc-gssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => nil,
        'provider'  => nil,
      })
    end
    # <OS independent resources>
  end

  describe 'with gss set to valid boolean true on Ubuntu 16.04' do
    let(:facts) { platform_facts['Ubuntu 16.04'] }
    let(:params) { { :gss => true } }

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'    => '/etc/default/nfs-common',
        'line'    => 'NEED_GSSD="yes"',
        'match'   => '^NEED_GSSD=.*',
        'notify'  => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('rpc-gssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => nil,
        'provider'  => 'systemd',
      })
    end
    # <OS independent resources>
  end

  describe 'with gss set to valid boolean true on Ubuntu 18.04' do
    let(:facts) { platform_facts['Ubuntu 18.04'] }
    let(:params) { { :gss => true } }

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'    => '/etc/default/nfs-common',
        'line'    => 'NEED_GSSD="yes"',
        'match'   => '^NEED_GSSD=.*',
        'notify'  => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('rpc-gssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => nil,
        'provider'  => 'systemd',
      })
    end
    # <OS independent resources>
  end

  describe 'with keytab set to valid absolute path /spec/test on RedHat 6' do
    let(:facts) { platform_facts['RedHat 6'] }
    let(:params) { { :keytab => '/spec/test' } }

    # <RHEL 6 specific resources>
    it { should_not contain_service('nfs-config') }
    # </RHEL 6 specific resources>

    # <OS independent resources>
    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'  => '/etc/sysconfig/nfs',
        'line'  => 'RPCGSSDARGS="-k /spec/test"',
        'match' => '^RPCGSSDARGS=.*',
      })
    end
    # </OS independent resources>
  end

  describe 'with keytab set to valid absolute path /spec/test on RedHat 7' do
    let(:facts) { platform_facts['RedHat 7'] }
    let(:params) { { :keytab => '/spec/test' } }

    # <RHEL 7 specific resources>
    it do
      should contain_exec('nfs-config').with({
        'command'     => 'service nfs-config start',
        'path'        => '/sbin:/usr/sbin',
        'refreshonly' => true,
        'subscribe'   => 'File_line[GSSD_OPTIONS]',
      })
    end

    # </RHEL 7 specific resources>

    # <OS independent resources>
    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'  => '/etc/sysconfig/nfs',
        'line'  => 'RPCGSSDARGS="-k /spec/test"',
        'match' => '^RPCGSSDARGS=.*',
      })
    end
    # </OS independent resources>
  end

  describe 'with keytab set to valid absolute path /spec/test on RedHat 8' do
    let(:facts) { platform_facts['RedHat 8'] }
    let(:params) { { :keytab => '/spec/test' } }

    it { should_not contain_exec('nfs-config') }
    it { should_not contain_file_line('GSSD_OPTIONS') }
  end

  describe 'with keytab set to valid absolute path /spec/test on Suse 11' do
    let(:facts) { platform_facts['Suse 11'] }
    let(:params) { { :keytab => '/spec/test' } }

    # <OS independent resources>
    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'  => '/etc/sysconfig/nfs',
        'line'  => 'GSSD_OPTIONS="-k /spec/test"',
        'match' => '^GSSD_OPTIONS=.*',
      })
    end
    # </OS independent resources>
  end

  describe 'with keytab set to valid absolute path /spec/test on Suse 12' do
    let(:facts) { platform_facts['Suse 12'] }
    let(:params) { { :keytab => '/spec/test' } }

    # <OS independent resources>
    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'  => '/etc/sysconfig/nfs',
        'line'  => 'GSSD_OPTIONS="-k /spec/test"',
        'match' => '^GSSD_OPTIONS=.*',
      })
    end
    # </OS independent resources>
  end

  describe 'with keytab set to valid absolute path /spec/test on Ubuntu 16.04' do
    let(:facts) { platform_facts['Ubuntu 16.04'] }
    let(:params) { { :keytab => '/spec/test' } }

    # <OS independent resources>
    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'  => '/etc/default/nfs-common',
        'line'  => 'GSSDARGS="-k /spec/test"',
        'match' => '^GSSDARGS=.*',
      })
    end
    # </OS independent resources>
  end

  describe 'with keytab set to valid absolute path /spec/test on Ubuntu 18.04' do
    let(:facts) { platform_facts['Ubuntu 18.04'] }
    let(:params) { { :keytab => '/spec/test' } }

    # <OS independent resources>
    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'  => '/etc/default/nfs-common',
        'line'  => 'GSSDARGS="-k /spec/test"',
        'match' => '^GSSDARGS=.*',
      })
    end
    # </OS independent resources>
  end

  describe 'with gss set to valid boolean true when keytab is set to valid absolute path /spec/test on RedHat 6' do
    let(:facts) { platform_facts['RedHat 6'] }
    let(:params) do
      {
        :gss    => true,
        :keytab => '/spec/test',
      }
    end

    # <RHEL 6 specific resources>
    it { should_not contain_service('nfs-config') }
    # </RHEL 6 specific resources>

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'    => '/etc/sysconfig/nfs',
        'line'    => 'SECURE_NFS="yes"',
        'match'   => '^SECURE_NFS=.*',
        'notify'  => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('rpcgssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => 'Service[idmapd_service]',
        'provider'  => nil,
      })
    end

    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'   => '/etc/sysconfig/nfs',
        'line'   => 'RPCGSSDARGS="-k /spec/test"',
        'match'  => '^RPCGSSDARGS=.*',
        'notify' => [ 'Service[rpcbind_service]', 'Service[rpcgssd]' ]
      })
    end
    # </OS independent resources>
  end

  describe 'with gss set to valid boolean true when keytab is set to valid absolute path /spec/test on RedHat 7' do
    let(:facts) { platform_facts['RedHat 7'] }
    let(:params) do
      {
        :gss    => true,
        :keytab => '/spec/test',
      }
    end

    # <RHEL 7 specific resources>
    it do
      should contain_exec('nfs-config').with({
        'command'     => 'service nfs-config start',
        'path'        => '/sbin:/usr/sbin',
        'refreshonly' => true,
        'subscribe'   => 'File_line[GSSD_OPTIONS]',
      })
    end

    it { should contain_service('rpcbind_service').with_before([ 'Service[rpc-gssd]' ]) }
    # </RHEL 7 specific resources>

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'   => '/etc/sysconfig/nfs',
        'line'   => 'SECURE_NFS="yes"',
        'match'  => '^SECURE_NFS=.*',
        'notify' => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('rpc-gssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => 'Service[idmapd_service]',
        'provider'  => nil,
      })
    end

    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'   => '/etc/sysconfig/nfs',
        'line'   => 'RPCGSSDARGS="-k /spec/test"',
        'match'  => '^RPCGSSDARGS=.*',
        'notify' => [ 'Service[rpcbind_service]', 'Service[rpc-gssd]' ]
      })
    end
    # </OS independent resources>
  end

  describe 'with gss set to valid boolean true when keytab is set to valid absolute path /spec/test on RedHat 8' do
    let(:facts) { platform_facts['RedHat 8'] }
    let(:params) do
      {
        :gss    => true,
        :keytab => '/spec/test',
      }
    end

    it { should contain_class('rpcbind') }

    it do
      should contain_service('rpc-gssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'Service[gss_service]',
        'require'   => 'Service[idmapd_service]',
        'provider'  => nil,
      })
    end

    it do
      should contain_service('gss_service').with({
        'ensure' => 'running',
        'enable' => 'true',
        'name'   => 'auth-rpcgss-module.service',
      })
    end

    it { should_not contain_exec('nfs-config') }
    it { should_not contain_file_line('NFS_SECURITY_GSS') }
    it { should_not contain_file_line('GSSD_OPTIONS') }
  end

  describe 'with gss set to valid boolean true when keytab is set to valid absolute path /spec/test on Suse 11' do
    let(:facts) { platform_facts['Suse 11'] }
    let(:params) do
      {
        :gss    => true,
        :keytab => '/spec/test',
      }
    end

    # <Suse 11 specific resources>
    it do
      should contain_file_line('NFS_START_SERVICES').with({
        'match'   => '^NFS_START_SERVICES=',
        'path'    => '/etc/sysconfig/nfs',
        'line'    => 'NFS_START_SERVICES="yes"',
        'notify'  => [ 'Service[nfs]', 'Service[rpcbind_service]' ]
      })
    end

    it do
      should contain_file_line('MODULES_LOADED_ON_BOOT').with({
        'match'   => '^MODULES_LOADED_ON_BOOT=',
        'path'    => '/etc/sysconfig/kernel',
        'line'    => 'MODULES_LOADED_ON_BOOT="rpcsec_gss_krb5"',
        'notify'  => 'Exec[gss-module-modprobe]',
      })
    end

    it do
      should contain_exec('gss-module-modprobe').with({
        'command'     => 'modprobe rpcsec_gss_krb5',
        'unless'      => 'lsmod | egrep "^rpcsec_gss_krb5"',
        'path'        => '/sbin:/usr/bin',
        'refreshonly' => true,
      })
    end
    # </Suse 11 specific resources>

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'    => '/etc/sysconfig/nfs',
        'line'    => 'NFS_SECURITY_GSS="yes"',
        'match'   => '^NFS_SECURITY_GSS=.*',
        'notify'  => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('nfs').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => nil,
        'provider'  => nil,
      })
    end

    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'   => '/etc/sysconfig/nfs',
        'line'   => 'GSSD_OPTIONS="-k /spec/test"',
        'match'  => '^GSSD_OPTIONS=.*',
        'notify' => [ 'Service[rpcbind_service]', 'Service[nfs]' ]
      })
    end
    # <OS independent resources>
  end

  describe 'with gss set to valid boolean true when keytab is set to valid absolute path /spec/test on Suse 12' do
    let(:facts) { platform_facts['Suse 12'] }
    let(:params) do
      {
        :gss    => true,
        :keytab => '/spec/test',
      }
    end

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'    => '/etc/sysconfig/nfs',
        'line'    => 'NFS_SECURITY_GSS="yes"',
        'match'   => '^NFS_SECURITY_GSS=.*',
        'notify'  => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('rpc-gssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => nil,
        'provider'  => nil,
      })
    end

    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'   => '/etc/sysconfig/nfs',
        'line'   => 'GSSD_OPTIONS="-k /spec/test"',
        'match'  => '^GSSD_OPTIONS=.*',
        'notify' => [ 'Service[rpcbind_service]', 'Service[rpc-gssd]' ]
      })
    end
    # <OS independent resources>
  end

  describe 'with gss set to valid boolean true when keytab is set to valid absolute path /spec/test on Ubuntu 16.04' do
    let(:facts) { platform_facts['Ubuntu 16.04'] }
    let(:params) do
      {
        :gss    => true,
        :keytab => '/spec/test',
      }
    end

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'    => '/etc/default/nfs-common',
        'line'    => 'NEED_GSSD="yes"',
        'match'   => '^NEED_GSSD=.*',
        'notify'  => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('rpc-gssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => nil,
        'provider'  => 'systemd',
      })
    end

    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'   => '/etc/default/nfs-common',
        'line'   => 'GSSDARGS="-k /spec/test"',
        'match'  => '^GSSDARGS=.*',
        'notify' => [ 'Service[rpcbind_service]', 'Service[rpc-gssd]' ]
      })
    end
    # </OS independent resources>
  end

  describe 'with gss set to valid boolean true when keytab is set to valid absolute path /spec/test on Ubuntu 18.04' do
    let(:facts) { platform_facts['Ubuntu 18.04'] }
    let(:params) do
      {
        :gss    => true,
        :keytab => '/spec/test',
      }
    end

    # <OS independent resources>
    it { should contain_class('rpcbind') }

    it do
      should contain_file_line('NFS_SECURITY_GSS').with({
        'path'    => '/etc/default/nfs-common',
        'line'    => 'NEED_GSSD="yes"',
        'match'   => '^NEED_GSSD=.*',
        'notify'  => 'Service[rpcbind_service]',
      })
    end

    it do
      should contain_service('rpc-gssd').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File_line[NFS_SECURITY_GSS]',
        'require'   => nil,
        'provider'  => 'systemd',
      })
    end

    it do
      should contain_file_line('GSSD_OPTIONS').with({
        'path'   => '/etc/default/nfs-common',
        'line'   => 'GSSDARGS="-k /spec/test"',
        'match'  => '^GSSDARGS=.*',
        'notify' => [ 'Service[rpcbind_service]', 'Service[rpc-gssd]' ]
      })
    end
    # </OS independent resources>
  end

  describe 'with defaults for all parameters on Debian 9' do
    let(:facts) do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '9.1',
        :operatingsystem        => 'Debian',
      }
    end
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /nfsclient module only supports/)
    end
  end

  describe 'variable type and content validations' do
    validations = {
      'absolute_path' => {
        :name    => %w(keytab),
        :valid   => ['/absolute/filepath','/absolute/directory/'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, nil],
        :message => 'is not an absolute path',
      },
      'boolean_stringified' => {
        :name    => %w(gss),
        :valid   => [true, false, 'true', 'false'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => 'str2bool',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        mandatory_params = {} if mandatory_params.nil?
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
