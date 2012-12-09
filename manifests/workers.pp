class stacktach::workers (
  $install_dir = $::stacktach::params::install_dir
) inherits stacktach::params {

  $packages = ['python-pip', 'python-dev', 'librabbitmq-dev']
  stacktach::requirements { $packages: }

  # hack because pympler isn't returned in pip freeze
  exec { 'install pympler':
    command => '/usr/bin/pip install pympler',
    creates => '/usr/local/lib/python2.7/dist-packages/pympler',
    require => Package['python-pip'],
  }

  $pip = ['librabbitmq', 'kombu']
  package { $pip:
    ensure   => present,
    provider => pip,
    require  => [Package['python-pip'], Package['python-dev'], Package['librabbitmq-dev']],
  }

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
    require    => Package['librabbitmq']
  }
}

