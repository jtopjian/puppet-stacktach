define stacktach::deployment (
  $rabbit_host,
  $rabbit_userid,
  $rabbit_password,
  $rabbit_port = '5672',
  $rabbit_virtual_host = '/',
  $install_dir = $::stacktach::params::install_dir,
  $durable_queue = false
) {

  include concat::setup

  concat::fragment { $name:
    target  => "${install_dir}/stacktach_worker_config.json",
    content => template('stacktach/deployment.erb'),
    order   => 02,
  }
}
