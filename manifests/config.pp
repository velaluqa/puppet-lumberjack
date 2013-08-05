# Class: lumberjack2::config
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
#   class { 'lumberjack2::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
# Edit: Kayla Green <mailto:kaylagreen771@gmail.com>
#
class lumberjack2::config {
    File {
        owner => root,
        group => root
    }
  
    $configdir = $lumberjack2::params::configdir

    if ($lumberjack2::ensure == 'present') {
        # Manage the single instance dir
        file { "${configdir}":
            ensure  => directory,
            mode    => '0644',
        }

        # Manage the single config dir
        file { "${configdir}/conf":
            ensure  => directory,
            mode    => '0640',
            purge   => true,
            recurse => true,
            require => File ["${configdir}"],
        }
          # Manage the single config dir
        file { "${configdir}/bin":
            ensure  => directory,
            mode    => '0644',
            require => File ["${configdir}"],
        }


        #Create network portion of config file
        $network = sorted_json({
            "network" => {
                "servers" => $lumberjack2::servers,
                "ssl ca"  => $lumberjack2::ssl_ca_path,
                "ssl certificate" => $lumberjack2::ssl_certificate,
                "ssl key" => $lumberjack2::ssl_key,
            }
        })
        
        #### Setup configuration files
        include concat::setup
        concat{ "${configdir}/conf/lumberjack2.conf":
            require => File["${configdir}/conf"],
        }

        # Add network portion of the config file
        concat::fragment{"default-start":
            target  => "${configdir}/conf/lumberjack2.conf",
            content => inline_template('<%= require "json"; "{" + network.to_json %>'),
            order   => 001,
        }  

        # <%= "{" + network.to_json %>'
        # Add the ending brackets and additional set of {} brackets needed to fix comma/json parsing issue
        concat::fragment{"default-end":
            target  => "${configdir}/conf/lumberjack2.conf",
            content => inline_template('"}" + "\n"'),
            order   => 999,
        }
        
    } else {
        # Remove the lumberjack2 directory and all of its configs. 
        file {$configdir : 
            ensure  => 'absent',
            purge   => true,
            recurse => true,
            force   => true,
        }
        
    }
}
