class site::stacktach::packages {


  package { 'python-pip':
    ensure => latest,
  }

  package { ['build-essential', 'python-dev', 'librabbitmq-dev']:
    ensure => latest,
  }

  package { ['python-mysqldb', 'python-django', 'libmysqlclient18', 'mysql-common']:
    ensure => latest,
  }

  package { ['librabbitmq', 'kombu']:
    ensure   => present,
    provider => pip,
    require  => [Package['build-essential'], Package['python-dev'], Package['librabbitmq-dev'], Package['python-pip']],
  }

  package { 'south':
    ensure   => present,
    provider => pip,
    require  => [Package['python-pip'], Package['python-django']],
  }

}
