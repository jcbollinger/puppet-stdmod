# Class: stdmod::params
#
# This class defines default parameters used by the main module class stdmod
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to stdmod class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class stdmod::params {

  ### Application related parameters

  $package = $::operatingsystem ? {
    default => 'stdmod',
  }

  $service = $::operatingsystem ? {
    default => 'stdmod',
  }

  $dir_path = $::operatingsystem ? {
    default => '/etc/stdmod',
  }

  $file_path = $::operatingsystem ? {
    default => '/etc/stdmod/stdmod.conf',
  }

  $file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $file_group = $::operatingsystem ? {
    default => 'root',
  }

}
