class stacktach::workers (
  $install_dir = $::stacktach::params::install_dir
) inherits stacktach::params {

  file { '/etc/init.d/stacktach':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('stacktach/stacktach.sh.erb'),
  }

  service { 'stacktach':
    ensure     => 'running',
    enable     => true,
    hasrestart => false,
    hasstatus  => false,
    status     => "ps aux | grep start_workers.py | grep -v grep",
  }

}
