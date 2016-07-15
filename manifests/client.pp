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

class bigfix::client(

  $license_file_url   = undef,       # The URL to *your* actionsite.afxm file. 
  $service_enable     = true,
  $service_ensure     = running,
  $package_ensure     = installed,
  $nocheckcertificate = true,        # Tells wget::fetch to enforce certificate check or not.
  $wget_timeout       = 0,           # Number of seconds to wait before giving up on wget.
){

  include bigfix::params

  if $license_file_url == undef {fail('The bigfix module requires $license_file_url') }
  validate_re($service_ensure, '^running|true|stopped|false$')
  validate_bool($service_enable)
  validate_bool($nocheckcertificate)

  $bes_dir = '/etc/opt/BESClient'

  file{$bes_dir:
    ensure => directory,
    before => Wget::Fetch[$license_file_url],
  }

  wget::fetch{$license_file_url:
    destination        => "${bes_dir}/actionsite.afxm",
    verbose            => true,
    nocheckcertificate => $nocheckcertificate,
    timeout            => $wget_timeout,
    require            => File[$bes_dir],
    before             => Service['besclient'],
  }

  service{'besclient':
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => Package['BESAgent'],
  }

  package{'BESAgent':
    ensure   => $package_ensure,
  }
}
