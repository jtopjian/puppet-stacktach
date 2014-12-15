class stacktach::configure {

  # Create the local_settings.py file
  $local_py = "${::stacktach::install_dir}/app/local_settings.py"
  file { $local_py:
    ensure => present,
    owner  => $::stacktach::user,
    group  => $::stacktach::group,
    mode   => '0640',
  }

  $::stacktach::django_config.each |$key, $value| {
    file_line { "${local_py} ${key}":
      path    => $local_py,
      line    => "${key} = '${value}'",
      match   => "^${key} =",
      notify  => Exec['sync stacktach database'],
      require => File[$local_py],
    }
  }

  # The Django wsgi.py file is missing from the repo
  # So it's included here
  file { "${::stacktach::install_dir}/app/wsgi.py":
    ensure  => present,
    owner   => $::stacktach::user,
    group   => $::stacktach::group,
    mode    => '0640',
    source  => 'puppet:///modules/stacktach/wsgi.py',
    require => Vcsrepo["${::stacktach::install_dir}/app"],
  }

  # The app directory needs __init__.pyh file so imports work
  file { "${::stacktach::install_dir}/app/__init__.py":
    ensure => present,
    owner  => $::stacktach::user,
    group  => $::stacktach::group,
    mode   => '0640',
  }

  # Configure verifier settings
  file { "${::stacktach::install_dir}/app/etc/stacktach_verifier_config.json":
    ensure  => present,
    owner   => $::stacktach::user,
    group   => $::stacktach::group,
    mode    => '0640',
    content => hash2json($::stacktach::verifier_config),
    require => Vcsrepo["${::stacktach::install_dir}/app"],
  }

  # Configure worker settings
  file { "${::stacktach::install_dir}/app/etc/stacktach_worker_config.json":
    ensure  => present,
    owner   => $::stacktach::user,
    group   => $::stacktach::group,
    mode    => '0640',
    content => hash2json($::stacktach::worker_config),
    notify  => Service['stacktach-workers'],
    require => Vcsrepo["${::stacktach::install_dir}/app"],
  }

  # Configure stacky
  file_line { "${::stacktach::install_dir}/stacky/stacky.py STACKTACH":
    path  => "${::stacktach::install_dir}/stacky/stacky.py",
    line  => "STACKTACH = 'http://${::fqdn}/'",
    match => '^STACKTACH =',
  }

  # Execs
  exec { 'sync stacktach database':
    command     => '/usr/bin/python manage.py syncdb --noinput',
    path        => ['/bin', '/usr/bin'],
    cwd         => "${::stacktach::install_dir}/app",
    environment => 'DJANGO_SETTINGS_MODULE=settings',
    refreshonly => true,
    notify      => Exec['migrate stacktach database'],
  }

  exec { 'migrate stacktach database':
    command     => '/usr/bin/python manage.py migrate',
    path        => ['/bin', '/usr/bin'],
    cwd         => "${::stacktach::install_dir}/app",
    environment => 'DJANGO_SETTINGS_MODULE=settings',
    refreshonly => true,
  }

}
