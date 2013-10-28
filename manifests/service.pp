# == Class: lumberjack::service
#
# This class exists to
# 1. Provide seperation between service creation and other aspects of the module
# 2. Provide a basis for future enhancements involving multiple running instances
#
# Therefore, many operating system dependent differences (names, paths, ...)
# are addressed in here.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class is not intended to be used directly.
#
#
# === Links
#
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#

# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
# Editor Ryan O'Keeffe

class lumberjack::service {

  $fullconfig      = "${lumberjack::configdir}/${lumberjack::config}"
  $cpuprofile      = $lumberjack::cpuprofile
  $idle_flush_time = $lumberjack::idle_flush_time
  $log_to_syslog   = $lumberjack::log_to_syslog
  $spool_size      = $lumberjack::spool_size
  $run_as_service  = $lumberjack::run_as_service
  $ensure          = $lumberjack::ensure
  $installdir      = $lumberjack::installdir

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
