define stacktach::requirements {
  if ! defined_with_params(Package[$name], {'ensure' => 'present' }) {
    package { $name:
      ensure => present,
    }
  }
}
