class stacktach::db::mysql (
  $db_password,
  $db_name     = $::stacktach::params::db_name,
  $db_host     = $::stacktach::params::db_host,
  $db_username = $::stacktach::params::db_username,
  $install_dir = $::stacktach::params::install_dir
) inherits stacktach::params {

  # Create the database
  mysql::db { $db_name:
    user     => $db_username,
    password => $db_password,
    host     => $db_host,
    grant    => ['all'],
    notify   => Exec['stacktach-db-sync'],
  }

  exec { 'stacktach-db-sync':
    refreshonly => true,
    command     => 'python manage.py syncdb --noinput',
    cwd         => "${install_dir}/app",
    environment => "PYTHONPATH=\$PYTHONPATH:${install_dir}/app",
    path        => ['/bin', '/usr/bin'],
  }
}
