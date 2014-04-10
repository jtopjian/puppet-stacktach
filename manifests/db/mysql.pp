class stacktach::db::mysql (
  $db_password,
  $db_name          = $::stacktach::params::db_name,
  $db_host          = $::stacktach::params::db_host,
  $db_username      = $::stacktach::params::db_username,
  $db_allowed_hosts = undef,
) inherits stacktach::params {

  # Create the database
  mysql::db { $db_name:
    user     => $db_username,
    password => $db_password,
    host     => $db_host,
    grant    => ['all'],
  }

  if is_array($db_allowed_hosts) and count($db_allowed_hosts) > 0 {
    $db_allowed_hosts.each |$host| {
      mysql_user { "${db_username}@${host}":
        password_hash => mysql_password($db_password),
      }

      mysql_grant { "${db_username}@${host}/${db_name}.*":
        privileges => ['ALL'],
        table      => "${db_name}.*",
        user       => "${db_username}@${host}",
        require    => Mysql_user["${db_username}@${host}"],
      }
    }
  }

}
