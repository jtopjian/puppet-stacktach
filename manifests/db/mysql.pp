class stacktach::db::mysql (
  $db_password,
  $db_name = 'stacktach',
  $db_user = 'stacktach',
  $db_host = 'localhost',
) {

  mysql::db { $db_name:
    user     => $db_user,
    password => $db_password,
    host     => $db_host,
    grant    => ['all'],
  }

}
