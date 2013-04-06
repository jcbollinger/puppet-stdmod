#
# Testing configuration file provisioning via template
# Auditing enabled
#
class { 'stdmod':
  template => 'stdmod/tests/test.conf',
  audit    => 'all',
}
