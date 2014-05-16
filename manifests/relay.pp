# == Class: bigfix::relay
#
# This class installs and configures the bigfix relay service.
# It is required that the bigfix::client be installed on any nodes
# hosting the relay service. Tested and verified on CentOS 6.4 and
# CentOS 6.5.
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
# [*bigfix::params::relay_url*]
#   This value returns the URL of the relay given the OS and desired version

# === Examples
#
# class { 'bigfix::relay':
#   license_file_url => 'http://my.server.com/bigfix/masthead.afxm'
#   version          => '9.0'
# }
#
# === Authors
#
# Timothy Scoppetta <tms@eecs.berkeley.edu>
#
# === Copyright
#
# Copyright 2014 Timothy Scoppetta, unless otherwise noted.

class bigfix::relay($license_file_url = undef, $version='9.1'){
  class {'bigfix::client':
    license_file_url => $license_file_url,
    version          => $version,
  }

  service{'besrelay':
    ensure  => running,
    require => Service['besclient'],
  }
  case $::operatingsystem {
    centos, redhat: {
      wget::fetch{$bigfix::params::relay_url:
        destination => '/tmp/BESRelay.rpm',
        before      => Package['BESRelay'],
      }
      package{'BESRelay':
        ensure   => installed,
        provider => rpm,
        source   => '/tmp/BESRelay.rpm',
        require  => Package['BESAgent']
      }
    }
    debian, ubuntu: {}
    default: {fail('Unrecognized operating system')}
  }

  firewall{'201 Allow all traffic on loopback':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }
  firewall {'202 accept related established rules':
    proto   => 'all',
    ctstate => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }
  firewall{'203 allow SSH':
    chain  => 'INPUT',
    proto  => 'tcp',
    dport  => '22',
    action => 'accept',
  }
  firewall{'204 allow TEM traffic':
    chain  => 'INPUT',
    proto  => 'udp',
    dport  => '52311',
    action => 'accept',
  }
  firewall{'205 allow ICMP ping for TEM traffic':
    chain  => 'INPUT',
    proto  => 'icmp',
    action => 'accept',
  }
  firewall{'206 allow UDP responses to DNS queries':
    chain  => 'INPUT',
    proto  => 'udp',
    sport  => '53',
    action => 'accept',
  }
}
