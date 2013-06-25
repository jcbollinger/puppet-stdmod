#
# = Define: stdmod::configfile
#
# The define manages stdmod configfile
#
#
# == Parameters
#
# [*ensure*]
#   String. Default: present
#   Manages configfile presence. Possible values:
#   * 'present' - Install package, ensure files are present.
#   * 'absent' - Stop service and remove package and managed files
#
# [*template*]
#   String. Default: Provided by the module.
#   Sets the path of a custom template to use as content of configfile
#   If defined, configfile file has: content => content("$template")
#   Example: template => 'site/configfile.conf.erb',
#
# [*options*]
#   Hash. Default undef. Needs: 'template'.
#   An hash of custom options to be used in templates to manage any key pairs of
#   arbitrary settings.
#
define stdmod::configfile (
  $ensure   = present,
  $template = 'stdmod/configfile.erb' ,
  $options  = '' ,
  $ensure  = present ) {

  # Note: it is safe to 'include' class stdmod here because (the accompanying
  # version of) that class is not parameterized.
  include stdmod

  file { "stdmod_configfile_${name}":
    ensure  => $ensure,
    path    => "${stdmod::dir_path}/${name}",
    mode    => $stdmod::file_mode,
    owner   => $stdmod::file_owner,
    group   => $stdmod::file_group,
    require => Package[$stdmod::package],
    notify  => $stdmod::file_notify,
    content => template($template),
    replace => $stdmod::file_replace,
    audit   => $stdmod::file_audit,
    noop    => $stdmod::noops,
  }

}
