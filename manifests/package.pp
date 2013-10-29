# == Class: lumberjack::package
#
# This class exists to coordinate all software package management related
# actions, functionality and logical units in a central place.
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
#   class { 'lumberjack::package': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class lumberjack::package {

  if ($lumberjack::manage_package == true) {

    #### Package management

    # set params: in operation
    if ($lumberjack::ensure == 'present') {

      # Check if we want to install a specific version or not
      if $lumberjack::version == false {

        $package_ensure = $lumberjack::autoupgrade ? {
          true  => 'latest',
          false => 'present',
        }

        } else {

        # install specific version
        $package_ensure = $lumberjack::version

        }

        # set params: removal
        } else {
        $package_ensure = 'absent'
        }

        # action
        package { $lumberjack::params::package :
          ensure => $package_ensure,
        }

  }
}
