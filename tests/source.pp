#
# Testing configuration file provisioning via source
# Auditing enabled
#
class { 'stdmod':
  source => 'puppet:///modules/stdmod/tests/test.conf',
  audit  => 'all',
}
