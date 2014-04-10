class stacktach::apache (
  $servername,
  $install_dir     = $::stacktach::params::install_dir,
  $apache_conf_dir = $::stacktach::params::apache_conf_dir,
  $www_user        = $::stacktach::params::www_user,
  $port            = 80,
  $ssl             = false,
  $ssl_cert        = undef,
  $ssl_key         = undef,
  $ssl_ca          = undef,
  $htpasswd        = false,
) inherits stacktach::params {

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service[$::stacktach::params::apache_service],
  }

  apache::vhost { $servername:
    servername          => $servername,
    default_vhost       => true,
    port                => $port,
    docroot             => '/var/www',
    ssl                 => $ssl,
    ssl_cert            => $ssl_cert,
    ssl_key             => $ssl_key,
    ssl_ca              => $ssl_ca,
    wsgi_process_group  => 'stacktach',
    wsgi_script_aliases => { '/' => "${install_dir}/wsgi/django.wsgi" },
  }

  file { "${install_dir}/wsgi":
    ensure => directory,
  }

  file { "${install_dir}/wsgi/django.wsgi":
    ensure  => present,
    content => template('stacktach/django.wsgi.erb'),
    require => File["${install_dir}/wsgi"],
  }

  file { "${apache_conf_dir}/stacktach.conf":
    ensure  => present,
    content => template('stacktach/apache.erb'),
  }

}
