# puppet-lumberjack

A puppet module for managing and configuring lumberjack

https://github.com/jordansissel/lumberjack/tree/lumberjack-hack

This module is based upon https://github.com/electrical/puppet-lumberjack 

This updated module is in the beta stage and although it is tested, not all scenarios may be covered.

## Usage

Installation, make sure service is running and will be started at boot time:

     class { 'lumberjack': 
       cpuprofile       => '/path/to/write/cpu/profile/to/file',
       idle_flush_time  => '5',
       log_to_syslog    => false,
       spool_size       => '1024',
       servers          => ['listof.hosts:12345', '127.0.0.1:9987'],
       ssl_ca           => '/path/to/ssl/root/certificate',
     }

Removal/decommissioning:

     class { 'lumberjack':
       ensure => 'absent',
     }

Install everything but disable service(s) afterwards:

     class { 'lumberjack':
       status => 'disabled',
     }

To configure file inputs:

    lumberjack::file { 'localhost-syslog':
        paths    => ['/var/log/messages','/var/log/secure','/var/log/*.log/'],
        fields   => { 'type' : 'syslog' }, 
    }

## Parameters

Default parameters have been set in the params.pp class file.  Options include config file and directory, package name, install dir (used by the service(s), amoung others.
