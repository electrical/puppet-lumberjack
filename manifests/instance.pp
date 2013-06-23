# Define: lumberjack::instance
#
# This define allows you to setup an instance of lumberjack
#
# === Parameters
#
# [*host*]
#   Host name or IP address of the Logstash instance to connect to
#   Value type is string
#   Default value: undef
#   This variable is optional
#
# [*port*]
#   Port number of the Logstash instance to connect to
#   Value type is number
#   Default value: undef
#   This variable is optional
#
# [*files*]
#   Array of files you wish to process
#   Value type is array
#   Default value: undef
#   This variable is optional
#
# [*ssl_ca_file*]
#   File to use for the SSL CA
#   Value type is string
#   This variable is mandatory
#
# [*fields*]
#   Extra fields to send
#   Value type is hash
#   Default value: false
#   This variable is optional
#
# [*run_as_service*]
#   Set this to true if you want to run this as a service.
#   Set to false if you only want to manage the ssl_ca_file
#   Value type is boolean
#   Default value: true
#   This variable is optional
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define lumberjack::instance(
  $ssl_ca_file,
  $host           = undef,
  $port           = undef,
  $files          = undef,
  $fields         = false,
  $run_as_service = true,
  $ensure         = $logstash::ensure
) {

  require lumberjack

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  if ($run_as_service == true ) {

    # Input validation
    validate_string($host)

    if ! is_numeric($port) {
      fail("\"${port}\" is not a valid port parameter value")
    }

    validate_array($files)
    $logfiles = join($files,' ')

    if $fields {
      validate_hash($fields)
    }

    # Setup init file if running as a service
    $notify_lumberjack = $lumberjack::restart_on_change ? {
      true  => Service["lumberjack-${name}"],
      false => undef,
    }

    file { "/etc/init.d/lumberjack-${name}":
      ensure  => $ensure,
      mode    => '0755',
      content => template("${module_name}/etc/init.d/lumberjack.erb"),
      notify  => $notify_lumberjack
    }

    #### Service management

    # set params: in operation
    if $lumberjack::ensure == 'present' {

      case $lumberjack::status {
        # make sure service is currently running, start it on boot
        'enabled': {
          $service_ensure = 'running'
          $service_enable = true
        }
        # make sure service is currently stopped, do not start it on boot
        'disabled': {
          $service_ensure = 'stopped'
          $service_enable = false
        }
        # make sure service is currently running, do not start it on boot
        'running': {
          $service_ensure = 'running'
          $service_enable = false
        }
        # do not start service on boot, do not care whether currently running or not
        'unmanaged': {
          $service_ensure = undef
          $service_enable = false
        }
        # unknown status
        # note: don't forget to update the parameter check in init.pp if you
        #       add a new or change an existing status.
        default: {
          fail("\"${lumberjack::status}\" is an unknown service status value")
        }
      }

    # set params: removal
    } else {

      # make sure the service is stopped and disabled (the removal itself will be
      # done by package.pp)
      $service_ensure = 'stopped'
      $service_enable = false
    }

    # action
    service { "lumberjack-${name}":
      ensure     => $service_ensure,
      enable     => $service_enable,
      name       => $lumberjack::params::service_name,
      hasstatus  => $lumberjack::params::service_hasstatus,
      hasrestart => $lumberjack::params::service_hasrestart,
      pattern    => $lumberjack::params::service_pattern,
    }

  } else {

    $notify_lumberjack = undef

  }


  file { "/etc/lumberjack/${name}":
    ensure => directory,
  }

  # Setup certificate files
  file { "/etc/lumberjack/${name}/ca.crt":
    ensure  => $ensure,
    source  => $ssl_ca_file,
    require => File[ "/etc/lumberjack/${name}" ],
    notify  => $notify_lumberjack
  }

}
