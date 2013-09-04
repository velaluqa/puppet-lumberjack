# Define: lumberjack2::instance
#
# This define allows you to setup an instance of lumberjack2
#
# === Parameters
#
# [*config*]
#   The config files' location to load
#   Value type is string
#   Default value: /etc/lumberjack2/<instance_name>/lumberjack2-conf.json
#   This variable is required
#
# [*cpuprofile*]
#   Write cpu profile to file
#   Value type is string
#   Default value: undef
#   This variable is optional
#
# [*idle-flush-time*]
#   Maximum time to wait for a full spool before flushing anyway
#   Value type is number 
#   Default value: 5 seconds
#   This variable is optional
#
# [*log-to-syslog*]
#   Log to syslog instead of stdout
#   Value type is string
#   Default value: false
#   This variable is optional
#
# [*spool-size*]
#   Maximum number of events to spool before a flush is forced.
#   Value type is number
#   Default value: `1024
#   This variable is optional
#
# [*servers*]
#   List of Host names or IP addresses of Logstash instances to connect to
#   Value type is array
#   Default value: undef
#   This variable is required
#
#
# [*ssl_ca_path*]
#   Path to file to use for the SSL CA
#   Value type is string
#   This variable is mandatory
#
# [*ssl_key*]
#   File to use for your SSL key
#   Value type is string
#   Default value: undef
#   This variable is optional
#
# [*ssl_certificate*]
#   File to use for your SSL certificate
#   Value type is string
#   Default value: undef
#   This variable is optional

#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#

class lumberjack2::service {

  $config = "${lumberjack2::configdir}/conf/lumberjack2.conf" 
  $cpuprofile = $lumberjack2::cpuprofile
  $idle_flush_time = $lumberjack2::idle_flush_time
  $log_to_syslog    = $lumberjack2::log_to_syslog
  $spool_size       = $lumberjack2::spool_size
  $run_as_service   = $lumberjack2::run_as_service          
  $ensure = $lumberjack2::ensure  
   
  validate_bool($run_as_service)

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  if ($run_as_service == true ) {
    # Setup init file if running as a service
    $notify_lumberjack2 = $lumberjack2::restart_on_change ? {
       true  => Service["lumberjack2"],
       false => undef,
    }

    file { '/etc/init.d/lumberjack2' :
      ensure  => $ensure,
      mode    => '0755',
      content => template("${module_name}/etc/init.d/lumberjack2.erb"),
      notify  => $notify_lumberjack2
    }

    #### Service management

    # set params: in operation
    if $lumberjack2::ensure == 'present' {

      case $lumberjack2::status {
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
          fail("\"${lumberjack2::status}\" is an unknown service status value")
        }
      }

    # set params: removal
    } else {

      # make sure the service is stopped and disabled (the removal itself will be
      # done by package.pp)
      $service_ensure = 'stopped'
      $service_enable = false
    }
    service { "lumberjack2":
            ensure     => $service_ensure,
            enable     => $service_enable,
            name       => $lumberjack2::params::service_name,
            hasstatus  => $lumberjack2::params::service_hasstatus,
            hasrestart => $lumberjack2::params::service_hasrestart,
            pattern    => $lumberjack2::params::service_pattern,
            require    => File['/etc/init.d/lumberjack2'],
    }
  } 
  else {
    $notify_lumberjack2 = undef
  }
}
