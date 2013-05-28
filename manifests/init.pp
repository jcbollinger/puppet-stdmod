#
# = Class: stdmod
#
# This class installs and manages stdmod
#
#
# == Parameters
#
# [*ensure*]
#   String. Default: present
#   Manages package installation and class resources. Possible values:
#   * 'present' - Install package, ensure files are present.
#   * 'absent' - Stop service and remove package and managed files
#
# [*version*]
#   String. Default: undef
#   If set, the defined package version is installed. Possible values:
#   * 'x.x.x'  - The version to install
#   * 'latest' - Ensure you have the latest available version.
#
# [*status*]
#   String. Default: enabled
#   Define the provided service status. Available values affect both the
#   ensure and the enable service arguments:
#   * 'enabled'     : ensure => running , enable => true
#   * 'disabled'    : ensure => stopped , enable => false
#   * 'running'     : ensure => running , enable => undef
#   * 'stopped'     : ensure => stopped , enable => undef
#   * 'activated'   : ensure => undef   , enable => true
#   * 'deactivated' : ensure => undef   , enable => false
#   * 'unmanaged'   : ensure => undef   , enable => undef
#
# [*autorestart*]
#   Boolean. Default: true
#   Define if changes to configurations automatically trigger a restart
#   of the relevant service(s)
#
# [*source*]
#   String or Array. Default: undef. Alternative to 'template'.
#   Sets the content of source parameter for main configuration file.
#   If defined, stdmod main config file will have the param: source => $source
#   Example: source => 'puppet:///modules/site/stdmod/stdmod.conf',
#
# [*dir_source*]
#   String or Array. Default: undef
#   If set, the main configuration dir is managed and its contents retrieved
#   from the specified source.
#   Example: dir_source => 'puppet:///modules/site/stdmod/conf.d/',
#
# [*dir_recurse*]
#   String. Default: true. Needs 'dir_source'.
#   Sets recurse parameter on the main configuration directory, if managed.
#   Possible values:
#   * 'true|int' - Regular recursion on both remote and local dir structure
#   * 'remote' - Descends recursively into the remote dir but not the local dir
#   * 'false - No recursion
#
# [*dir_purge*]
#   Boolean. Default: false
#   If set to true the existing configuration directory is
#   mirrored with the content retrieved from dir_source
#
# [*template*]
#   String. Default: undef. Alternative to 'source'.
#   Sets the path to the template to use as content for main configuration file
#   If defined, stdmod main config file has: content => content("$template")
#   Example: template => 'site/stdmod.conf.erb',
#
# [*options*]
#   Hash. Default undef. Needs: 'template'.
#   An hash of custom options to be used in templates to manage any key pairs of
#   arbitrary settings.
#
# [*dependency_class*]
#   String. Default: stdmod::dependency
#   Name of a class that contains resources needed by this module but provided
#   by external modules. You may leave the default value to keep the
#   default dependencies as declared in stdmod/manifests/dependency.pp
#   or define a custom class name where the same resources are provided
#   with custom ways or via other modules.
#   Set to undef to not include any dependency class.
#
# [*my_class*]
#   String. Default undef.
#   Name of a custom class to autoload to manage module's customizations
#   If defined, stdmod class will automatically "include $my_class"
#   Example: my_class => 'site::my_stdmod',
#
# [*audits*]
#   String or array. Default: undef.
#   Applies audit metaparameter to managed files.
#   Ref: http://docs.puppetlabs.com/references/latest/metaparameter.html#audit
#   Possible values:
#   * '<attribute>' - A name of the attribute to audit.
#   * [ '<attr1>' , '<attr2>' ] - An array of attributes.
#   * 'all' - Audit all the attributes.
#
# [*noops*]
#   Boolean. Default: false.
#   Set noop metaparameter to true for all the resources managed by the module.
#   If true no real change is done is done by the module on the system.
#
class stdmod (

  $ensure              = 'present',
  $version             = undef,

  $status              = 'enabled',
  $autorestart         = true,

  $source              = undef,
  $dir_source          = undef,
  $dir_recurse         = true,
  $dir_purge           = false,

  $template            = undef,
  $options             = undef,

  $dependency_class    = 'stdmod::dependency',
  $my_class            = undef,

  $audits              = undef,
  $noops               = undef

  ) {

  ### Input parameters validation
  validate_re($ensure, ['present','absent'], 'Valid values are: present, absent')
  validate_string($version)
  validate_re($status, ['enabled','disabled','running','stopped','activated','deactivated','unmanaged'], 'Valid values are: enabled, disabled, running, stopped, activated, deactivated and unmanaged')
  validate_bool($autorestart)
  validate_bool($dir_recurse)
  validate_bool($dir_purge)
  if $options { validate_hash($options) }
  if $noops { validate_bool($noops) }

  ### Variables defined in stdmod::params
  include stdmod::params

  $package=$stdmod::params::package
  $service=$stdmod::params::service
  $file_path=$stdmod::params::file_path
  $dir_path=$stdmod::params::dir_path
  $file_mode=$stdmod::params::file_mode
  $file_owner=$stdmod::params::file_owner
  $file_group=$stdmod::params::file_group

  ### Internal variables (that map class parameters)
  if $stdmod::ensure == 'present' {

    $package_ensure = $stdmod::version ? {
      ''      => 'present',
      default => $stdmod::version,
    }

    $service_enable = $stdmod::status ? {
      'enabled'     => true,
      'disabled'    => false,
      'running'     => undef,
      'stopped'     => undef,
      'activated'   => true,
      'deactivated' => false,
      'unmanaged'   => undef,
    }

    $service_ensure = $stdmod::status ? {
      'enabled'     => 'running',
      'disabled'    => 'stopped',
      'running'     => 'running',
      'stopped'     => 'stopped',
      'activated'   => undef,
      'deactivated' => undef,
      'unmanaged'   => undef,
    }

    $dir_ensure = directory
    $file_ensure = present

  } else {

    $package_ensure = 'absent'
    $service_enable = undef
    $service_ensure = stopped
    $dir_ensure = absent
    $file_ensure = absent

  }

  $file_notify = $stdmod::autorestart ? {
    true    => Service['stdmod'],
    false   => undef,
  }

  $file_audit = $stdmod::audits

  $file_replace = $stdmod::audits ? {
    ''      => true,
    default => false,
  }

  $file_source = $stdmod::source

  $file_content = $stdmod::template ? {
    ''        => undef,
    default   => template($stdmod::template),
  }


  ### Resources managed by the module

  package { $stdmod::package:
    ensure  => $stdmod::package_ensure,
    noop    => $stdmod::noops,
  }

  service { $stdmod::service:
    ensure     => $stdmod::service_ensure,
    enable     => $stdmod::service_enable,
    require    => Package[$stdmod::package],
    noop       => $stdmod::noops,
  }

  file { 'stdmod.conf':
    ensure  => $stdmod::file_ensure,
    path    => $stdmod::file_path,
    mode    => $stdmod::file_mode,
    owner   => $stdmod::file_owner,
    group   => $stdmod::file_group,
    require => Package[$stdmod::package],
    notify  => $stdmod::file_notify,
    source  => $stdmod::file_source,
    content => $stdmod::file_content,
    replace => $stdmod::file_replace,
    audit   => $stdmod::file_audit,
    noop    => $stdmod::noops,
  }

  # Configuration Directory, if dir_source defined
  if $stdmod::dir_source {
    file { 'stdmod.dir':
      ensure  => $stdmod::dir_ensure,
      path    => $stdmod::dir_path,
      require => Package[$stdmod::package],
      notify  => $stdmod::file_notify,
      source  => $stdmod::dir_source,
      recurse => $stdmod::dir_recurse,
      purge   => $stdmod::dir_purge,
      force   => $stdmod::dir_purge,
      replace => $stdmod::file_replace,
      audit   => $stdmod::file_audit,
      noop    => $stdmod::noops,
    }
  }


  ### Extra classes
  if $stdmod::dependency_class {
    include $stdmod::dependency_class
  }

  if $stdmod::my_class {
    include $stdmod::my_class
  }

}
