class stacktach (
  $db_password,
  $db_engine   = $::stacktach::params::db_engine,
  $db_name     = $::stacktach::params::db_name,
  $db_host     = $::stacktach::params::db_host,
  $db_port     = $::stacktach::params::db_port,
  $db_username = $::stacktach::params::db_username,
  $install_dir = $::stacktach::params::install_dir,
  $log_dir     = $::stacktach::params::log_dir,
  $www_user    = $::stacktach::params::www_user,
  $deployments = {},
  $verifier    = {},
) inherits stacktach::params {

  $stacktach_dir = "${install_dir}/app"

  # File globals
  File {
    ensure => present,
    owner  => $www_user,
    group  => $www_user,
    mode   => '0640',
  }

  file { $log_dir:
    ensure => directory,
  }

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
  } ->

  # Create a config file
  file { "${install_dir}/stacktach_config.sh":
    ensure  => present,
    content => template('stacktach/stacktach_config.sh.erb'),
  } ->

  file { "${stacktach_dir}/__init__.py":
    ensure => present,
  } ->

  # Create a local_settings file -- like a config file
  file { "${stacktach_dir}/local_settings.py":
    ensure  => present,
    content => template('stacktach/local_settings.py.erb'),
  } ->

  file { "${install_dir}/stacktach_worker_config.json":
    content => hash2json($deployments),
    notify  => Exec['stacktach-db-sync'],
  } ->

  file { "${install_dir}/stacktach_verifier_config.json":
    content => hash2json($verifier),
    notify  => Exec['stacktach-db-sync'],
  }

  exec { 'stacktach-db-sync':
    refreshonly => true,
    command     => 'python manage.py syncdb --noinput',
    cwd         => "${install_dir}/app",
    environment => 'DJANGO_SETTINGS_MODULE=settings',
    path        => ['/bin', '/usr/bin'],
    require     => File["${install_dir}/stacktach_verifier_config.json"],
    notify      => Exec['stacktach-migrate'],
  }

  exec { 'stacktach-migrate':
    refreshonly => true,
    command     => 'python manage.py migrate',
    cwd         => "${install_dir}/app",
    environment => 'DJANGO_SETTINGS_MODULE=settings',
    path        => ['/bin', '/usr/bin'],
    require     => Exec['stacktach-db-sync'],
  }

}
