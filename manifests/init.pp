#
class stacktach (
  $db_password,
  $db_type     = 'mysql',
  $db_name     = $::stacktach::params::db_name,
  $db_host     = $::stacktach::params::db_host,
  $db_username = $::stacktach::params::db_username,
  $install_dir = $::stacktach::params::install_dir
) inherits stacktach::params {

  include concat::setup

  $stacktach_dir = "${install_dir}/app"

  # File globals
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  # Install required packages if they aren't already installed
  $packages = ['python-eventlet', 'python-django', 'libapache2-mod-wsgi', 'python-mysqldb']
  stacktach::requirements { $packages: }

  # Ensure the install_dir exists
  file { $install_dir:
    ensure => directory,
  }

  # Check the latest stacktach out of git
  vcsrepo { $stacktach_dir:
    provider => git,
    ensure   => present,
    source   => 'https://github.com/rackerlabs/stacktach',
    require  => File[$install_dir],
  }

  # Create a config file
  file { "${install_dir}/stacktach_config.sh":
    ensure  => present,
    content => template('stacktach/stacktach_config.sh.erb'),
    require => Vcsrepo[$stacktach_dir],
  }

  # Create a local_settings file -- like a config file
  file { "${stacktach_dir}/local_settings.py":
    ensure  => present,
    content => template('stacktach/local_settings.py.erb'),
  }

 # Create a worker config file
  concat { "${install_dir}/stacktach_worker_config.json":
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  # the header for the worker config file
  concat::fragment { 'stacktach header':
    target  => "${install_dir}/stacktach_worker_config.json",
    content => template('stacktach/deployment.header.erb'),
    order   => 01,
  }

  # the footer for the worker config file
  concat::fragment { 'stacktach footer':
    target  => "${install_dir}/stacktach_worker_config.json",
    content => template('stacktach/deployment.footer.erb'),
    order   => 99,
  }

  case $db_type {
    'mysql': {
      class { 'stacktach::db::mysql':
        db_name     => $db_name,
        db_host     => $db_host,
        db_username => $db_username,
        db_password => $db_password,
        install_dir => $install_dir,
      }
    }
  }
}
