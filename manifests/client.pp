# == Class: bigfix::client
#
# This class installs and configures the bigfix agent on client
# systems. This not only required for standalone clients but as a
# prerequisite to creating a bigfix relay. This class has been tested
# and verified on CentOS 6.4, CentOS 6.5, and Ubuntu 12.04.
#
# === Parameters
#
# [*license_file_url*]
#   URL of the license file necessary to configure the client.
# [*version*]
#   Desired version of the bigfix agent
#
# === Variables
#
# [*bigfix::params::agent_url*]
#   This value returns the URL of the agent given the OS and desired version
#
# === Examples
#
# class { 'bigfix::client':
#   license_file_url => 'http://my.server.com/bigfix/masthead.afxm'
#   version          => '9.0'
# }
#
# === Authors
#
# Timothy Scoppetta (tms@eecs.berkeley.edu)
#
# === Copyright
#
# Copyright 2014 Timothy Scoppetta, unless otherwise noted.

class bigfix::client($license_file_url = undef, $version='9.1'){
  include bigfix::params

  if $license_file_url == undef {
    fail('The bigfix module requires $license_file_url')
  }
  file{'/etc/opt/BESClient':
    ensure => directory,
  }
  wget::fetch{$license_file_url:
    destination => '/etc/opt/BESClient/actionsite.afxm',
    verbose     => true,
    require     => File['/etc/opt/BESClient'],
    before      => Service['besclient'],
  }
  service{'besclient':
    ensure  => running,
    require => Package['BESAgent'],
  }
  case $::operatingsystem {
    centos, redhat: {
      wget::fetch{$bigfix::params::agent_url:
        destination => '/tmp/BESAgent.rpm',
        before      => Package['BESAgent'],
      }
      package{'BESAgent':
        ensure   => installed,
        provider => rpm,
        source   => '/tmp/BESAgent.rpm',
      }
    }
    debian, ubuntu: {
      wget::fetch{$bigfix::params::agent_url:
        destination => '/tmp/BESAgent.deb',
        before      => Package['BESAgent'],
      }
      package{'BESAgent':
        ensure   => installed,
        provider => dpkg,
        source   => '/tmp/BESAgent.deb',
      }
    }
    default: {fail('Unrecognized operating system')}
  }
}
