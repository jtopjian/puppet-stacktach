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

}
