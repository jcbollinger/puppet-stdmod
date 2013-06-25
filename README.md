# Puppet module: stdmod

This is a Puppet module for stdmod.
It manages its installation, configuration and service.

The blueprint of this module is from http://github.com/Example42-templates/

Released under the terms of Apache 2 License.


## USAGE - Basic management

* To declare stdmod managed on the target node, simply declare class 'stdmod':

        include 'stdmod'

Absent any customization, that will ensure the package installed, configuration
files set up with default settings (as defined by this module), and the
service started.

Customization options for stdlib are provided as external data, accessed by the
module via Hiera.  Important data and their uses include

* To ensure stdmod and all it managed files absent, and the service stopped:

        stdmod::ensure: "absent"

* To ensure a specific version of the stdmod package (e.g. v1.0.1) is used:

        stdmod::version: "1.0.1"

* To ensure that the most recent available version of the stdmod package is used:

        stdmod::version: "latest"

* To ensure the stdmod service is running, and is configured to start at system boot (this is default):

        stdmod::status: "enabled"

* To ensure the stdmod service is not running, and is not configured to start at system boot:

        stdmod::status: "disabled"

* To ensure the stdmod service is running without managing whether it is configured to start at system boot:

        stdmod::status: "running"

* To ensure the stdmod service is not configured to start at system boot, without managing
  whether it is currently running:

        stdmod::status: "deactivated"

* To avoid automatically restarting the service when its configuration file(s) changes:

        stdmod::autorestart: "false"

* To avoid managing anything about when the service starts or whether it is running:

        stdmod::status: "unmanaged"

* To audit changes to specified (or all) properties of stdmod configuration *files*

        stdmod::audit: ["mtime", "type"]

  or

        stdmod::audit: "all"

* To avoid changing any of the module's managed resources, instead only reporting what needs to be done:

        stdmod::noops: "true"


## ADVANCED USAGE - Overrides and Customizations
* To define a custom source for the main configuration file (first one found wins):

        stdmod::source:
          - "puppet:///modules/example42/stdmod/stdmod.conf-%{hostname}"
          - "puppet:///modules/example42/stdmod/stdmod.conf"

* To define a custom source directory for the whole configuration dir:

        stdmod::dir_source: "puppet:///modules/example42/stdmod/conf/"

* To define a custom source directory for the whole configuration dir *and* purge all the local files that are present in the remote source.
  Note: This mode can will ensure that the content of a directory is exactly as defined on the server; it will remove otherwise unmanaged files:

        stdmod::dir_source: "puppet:///modules/example42/stdmod/conf/"
        stdmod::dir_purge:  "true"

* To define a custom source directory for the whole configuration dir, excluding the contents
 of any subdirectories (which are recursively included by default):

        stdmod::dir_source:    "puppet:///modules/example42/stdmod/conf/"
        stdmod::dir_recursion: "false"

* To define a custom template for the main config file. Note that template and source arguments are mutually exclusive: 

        stdmod::template: "example42/stdmod/stdmod.conf.erb"

* To provide a hash of custom options for use inside the config file template:

        stdmod::options:
            opt:  'value'
            opt2: 'value2'

* To identify a custom class that provides dependencies required by the module for full functionality.
  Use this if you want to use alternative modules to manage dependencies:

        stdmod::dependency_class: "example42::dependency_stdmod"

* To identify a custom class with extra resources related to stdmod.  The module will declare it.

        stdmod::my_class: 'example42::my_stdmod'

## TESTING
