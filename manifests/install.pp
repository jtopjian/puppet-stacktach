class stacktach::install {

  # Install the mysql client dev package
  # This is so the python module can buld
  package { 'libmysqlclient-dev':
    ensure => present,
  }

  # Configure Python
  class { 'python':
    version    => 'system',
    pip        => true,
    dev        => true,
    virtualenv => true,
    gunicorn   => true,
  }

  # Ensure the install directory exists with the correct permissions
  file { $::stacktach::install_dir:
    ensure  => directory,
    owner   => $::stacktach::user,
    group   => $::stacktach::group,
    mode    => '0640',
    require => User[$::stacktach::user],
  }

  # Clone the latest stacktach repo
  vcsrepo { "${::stacktach::install_dir}/app":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/rackerlabs/stacktach',
    user     => $::stacktach::user,
    group    => $::stacktach::group,
    require  => File[$::stacktach::install_dir],
  }

  # Clone the latest stacky
  vcsrepo { "${::stacktach::install_dir}/stacky":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/rackerlabs/stacky',
    user     => $::stacktach::user,
    group    => $::stacktach::group,
    require  => File[$::stacktach::install_dir],
  }

  python::requirements { "${::stacktach::install_dir}/app/etc/pip-requires.txt" :
    require => [Vcsrepo["${::stacktach::install_dir}/app"], Package['libmysqlclient-dev']],
    notify  => Exec['sync stacktach database'],
  }

  file { '/var/log/stacktach':
    ensure => directory,
    owner   => $::stacktach::user,
    group   => $::stacktach::group,
    mode   => '0640',
  }

}
