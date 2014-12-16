class stacktach (
  $user              = 'www-data',
  $group             = 'www-data',
  $install_dir       = '/opt/stacktach',
  $htpasswd_file     = false,
  $htpasswd_username = false,
  $htpasswd_password = false,
  $django_config     = {},
  $verifier_config   = {},
  $worker_config   =   {},
) {

  anchor { 'stacktach::start': } ->
  class { 'stacktach::install': } ->
  class { 'stacktach::configure': } ->
  class { 'stacktach::services': } ->
  class { 'stacktach::apache': } ->
  anchor { 'stacktach::end': }

}
