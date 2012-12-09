class stacktach::apache (
  $conf_dir    = $::stacktach::params::apache_conf,
  $web_entry   = $::stacktach::params::web_entry,
  $install_dir = $::stacktach::params::install_dir
) inherits stacktach::params {

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service[$::stacktach::params::apache_service],
  }

  file { "${install_dir}/wsgi":
    ensure => directory,
  }

  # Modify STATIC_URL in settings.py
  file_line { 'settings.py STATIC_URL':
    path  => "${install_dir}/app/settings.py",
    line  => "STATIC_URL = '${web_entry}/static/'",
    match => "^STATIC_URL =",
  }
 
  file { "${install_dir}/wsgi/django.wsgi":
    ensure  => present,
    content => template('stacktach/django.wsgi.erb'),
    require => File["${install_dir}/wsgi"],
  }

  file { "${conf_dir}/stacktach.conf":
    ensure  => present,
    content => template('stacktach/apache.erb'),
  }
}
