# Define: lumberjack::instance
#
# This define allows you to setup an instance of lumberjack
#
# === Parameters
#
# [*config*]
#   The config files' location to load
#   Value type is string
#   Default value: /etc/lumberjack/<instance_name>/lumberjack-conf.json
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

class lumberjack::service {

  $config = "${lumberjack::config}/lumberjack.conf" 
  $cpuprofile = $lumberjack::cpuprofile
  $idle_flush_time = $lumberjack::idle_flush_time
  $log_to_syslog    = $lumberjack::log_to_syslog
  $spool_size       = $lumberjack::spool_size
  $run_as_service   = $lumberjack::run_as_service          
  $ensure = $lumberjack::ensure  
  $installpath = $lumberjack::installpath

  validate_bool($run_as_service)

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  if ($run_as_service == true ) {
    # Setup init file if running as a service
    $notify_lumberjack = $lumberjack::restart_on_change ? {
       true  => Service["lumberjack"],
       false => undef,
    }

    file { '/etc/init.d/lumberjack' :
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
    service { "lumberjack":
            ensure     => $service_ensure,
            enable     => $service_enable,
            name       => $lumberjack::params::service_name,
            hasstatus  => $lumberjack::params::service_hasstatus,
            hasrestart => $lumberjack::params::service_hasrestart,
            pattern    => $lumberjack::params::service_pattern,
            require    => File['/etc/init.d/lumberjack'],
    }
  } 
  else {
    $notify_lumberjack = undef
  }
}
