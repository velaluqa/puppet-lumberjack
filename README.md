# puppet-lumberjack2

A puppet module for managing and configuring lumberjack2

https://github.com/jordansissel/lumberjack/tree/lumberjack2-hack

This module is based upon https://github.com/electrical/puppet-lumberjack 

This updated module is in alpha stages and not yet formally tested.

## Usage

Installation, make sure service is running and will be started at boot time:

     class { 'lumberjack2': 
       cpuprofile       => '/path/to/write/cpu/profile/to/file',
       idle_flush_time  => '5',
       log_to_syslog    => false,
       spool_size       => '1024',
       servers          => ['listof.hosts:12345', '127.0.0.1:9987'],
       ssl_ca           => '/path/to/ssl/root/certificate',
     }

Removal/decommissioning:

     class { 'lumberjack2':
       ensure => 'absent',
     }

Install everything but disable service(s) afterwards:

     class { 'lumberjack2':
       status => 'disabled',
     }

To configure file inputs:
    lumberjack2::file { 'localhost-syslog':
        paths    => ['/var/log/messages','/var/log/secure','/var/log/*.log/'],
        fields   => { 'type' : 'syslog' }, 
    }
