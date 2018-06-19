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
#
# [*license_file*]
#   The path to the actual license file to use for the client.
#
# [*service_enable*]
#   Enable/Disable the service on reboot.
#
# [*service_ensure*]
#   Should the service be running or stopped.
#
# [*package_ensure*]
#   Should the BESAgent be installed or removed.
#
# [*nocheckcertificate*]
#   Permits downloading (via wget) without having the SSL certificate.
#
# [*wget_timeout*]
#   How long to wait before giving up on [potentially] unreachable URLs.
#
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

  $license_file_url   = undef,       # The URL to *your* actionsite.afxm file.  Mutually exclusive with $license_file.
  $license_file       = undef,       # The actual actionsite.afxm file.  Mutually exclusive with $license_file_url.
  $service_enable     = true,
  $service_ensure     = running,
  $package_ensure     = installed,
  $nocheckcertificate = true,        # Tells wget::fetch to enforce certificate check or not.
  $wget_timeout       = 0,           # Number of seconds to wait before giving up on wget.
  $version            = '9.1',

){

  include bigfix::params

  if ($license_file_url == undef) and ($license_file == undef) {fail('The bigfix module requires $license_file or $license_file_url to be defined.') }
  if ($license_file_url) and ($license_file) {fail('Either $license_file or $license_file_url may be defined, but not both.') }

  # $Service_ensure can be string or boolean.  Check for both.
  case type3x($service_ensure) {
    'string': {
      validate_re($service_ensure, '^running|true|stopped|false$')
    }
    'boolean': { }  # Nothing to do if it's a boolean.
    default: {
      fail('bigfix::client::service_ensure must be running, stopped, true, false or BOOLEAN.')
    }
  }

  validate_bool($service_enable)
  validate_bool($nocheckcertificate)

  $bes_dir = '/etc/opt/BESClient'

  file{$bes_dir:
    ensure => directory,
#    before => Wget::Fetch[$license_file_url],
  }

  $actionsite_file = "${bes_dir}/actionsite.afxm"

  if $license_file_url {
    wget::fetch{$license_file_url:
      destination        => $actionsite_file,
      verbose            => true,
      nocheckcertificate => $nocheckcertificate,
      timeout            => $wget_timeout,
      require            => File[$bes_dir],
      before             => Service['besclient'],
      notify             => Service['besclient'],
    }
  }

  else {
    file {$actionsite_file:
      ensure  => file,
      path    => $actionsite_file,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => File[$bes_dir],
      before  => Service['besclient'],
      source  => $license_file,
      notify  => Service['besclient'],
    }
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
