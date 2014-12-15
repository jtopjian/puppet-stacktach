class stacktach::services {

  file { '/etc/init/stacktach-workers.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('stacktach/stacktach-workers.conf.erb'),
  }

  service { 'stacktach-workers':
    enable   => true,
    ensure   => running,
    provider => 'upstart',
    require  => File['/etc/init/stacktach-workers.conf'],
  }

  python::gunicorn { 'stacktach':
    ensure     => present,
    appmodule  => 'app.wsgi',
    dir        => "${::stacktach::install_dir}",
    bind       => '[::1]:8000',
    owner      => $::stacktach::user,
    group      => $::stacktach::group,
    require    => [Python::Requirements["${::stacktach::install_dir}/app/etc/pip-requires.txt"], File["${::stacktach::install_dir}/app/wsgi.py"]],
  }

}
