# == Class: bigfix::params
#
#  This class manages parameters relating to the installation of the
#  bigfix agent and relay.
#
# === Parameters
#
# === Variables
#
# [*bigfix::client::version*]
#   The desired version of the client/relay packages (defaults to 9.1)
#
# === Authors
#
# Timothy Scoppetta (tms@eecs.berkeley.edu)
#
# === Copyright
#
# Copyright 2014 Timothy Scoppetta, unless otherwise noted.

class bigfix::params{
  if $bigfix::client::version == '9.1'{
    case $::operatingsystem {
      centos, redhat: {
        $agent_url='http://software.bigfix.com/download/bes/91/BESAgent-9.1.1082.0-rhe5.x86_64.rpm'
        $server_url='http://software.bigfix.com/download/bes/91/ServerInstaller_9.1.1082.0-rhe6.x86_64.tgz'
        $relay_url='http://software.bigfix.com/download/bes/91/BESRelay-9.1.1082.0-rhe5.x86_64.rpm'
      }
      debian, ubuntu: {
        $agent_url='http://software.bigfix.com/download/bes/91/BESAgent-9.1.1082.0-ubuntu10.amd64.deb'
      }
    }
    } elsif $bigfix::client::version == '9.0' {
    case $::operatingsystem {
      centos, redhat: {
        $agent_url='http://software.bigfix.com/download/bes/90/BESAgent-9.0.787.0-rhe5.x86_64.rpm'
        $relay_url='http://software.bigfix.com/download/bes/90/BESRelay-9.0.787.0-rhe5.x86_64.rpm'
      }
      debian, ubuntu: {
        $agent_url='http://software.bigfix.com/download/bes/90/BESAgent-9.0.787.0-ubuntu10.amd64.deb'
      }
    }
    } else {
      fail('Unsupported version')
    }
}
