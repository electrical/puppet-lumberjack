# puppet-lumberjack

A puppet module for managing and configuring lumberjack

https://github.com/jordansissel/lumberjack

This module is puppet 3 tested

## Usage

Installation, make sure service is running and will be started at boot time:

     lumberjack::instance { 'foo': 
       host  => 'logstashhost',
       port  => '7200',
       files => ['/var/log/messages', '/var/log/thing/*'],
       ssl_ca_path => "puppet:///path/to/ca.crt",
     }

Removal/decommissioning:

     class { 'lumberjack':
       ensure => 'absent',
     }

Install everything but disable service(s) afterwards:

     class { 'lumberjack':
       status => 'disabled',
     }

