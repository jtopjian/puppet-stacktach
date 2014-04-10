class stacktach::params {
  $db_engine   = 'django.db.backends.mysql'
  $db_name     = 'stacktach'
  $db_host     = 'localhost'
  $db_port     = 3306
  $db_username = 'stacktach'
  $install_dir = '/var/www/stacktach'
  $log_dir     = '/var/log/stacktach'

  case $::osfamily {
    'Debian': {
      $apache_conf_dir = '/etc/apache2/conf.d'
      $apache_service  = 'apache2'
      $www_user        = 'www-data'
    }
  }

}
