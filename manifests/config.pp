# == Class: lumberjack::config
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'lumberjack::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class lumberjack::config {

  #### Configuration

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  file { '/etc/init.d/lumberjack':
    ensure  => present,
    mode    => '0755',
    content => template("${module_name}/etc/init.d/lumberjack.erb")
  }

  file { '/etc/lumberjack':
    ensure => directory,
  }

  file { '/etc/lumberjack/ca.crt':
    ensure  => present,
    source  => $lumberjack::ssl_ca_path,
    require => File[ '/etc/lumberjack' ]
  }

}
