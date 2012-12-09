class stacktach::stacky (
  $stacktach_url,
  $install_dir = $::stacktach::params::install_dir
) inherits stacktach::params {

  $packages = ['python-prettytable']
  stacktach::requirements { $packages: }

  $pip = ['requests']
  package { $pip:
    ensure   => present,
    provider => pip,
    require  => Package['python-pip'],
  }

  vcsrepo { "${install_dir}/stacky":
    provider => git,
    ensure   => present,
    source   => 'https://github.com/rackspace/stacky',
  }

  file { "${install_dir}/stacky/stackyrc":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "export STACKTACH_URL=$stacktach_url\n",
  }
}
