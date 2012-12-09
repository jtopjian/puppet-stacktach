class stacktach::params {
  $db_name     = 'stacktach'
  $db_host     = 'localhost'
  $db_username = 'stacktach'
  $install_dir = '/var/www/stacktach'
  $web_entry   = '/stacktach'

  case $::osfamily {
    'Debian': {
      $apache_conf    = '/etc/apache2/conf.d'
      $apache_service = 'apache2'
    }
  }

}
