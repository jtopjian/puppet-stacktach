class stacktach::apache {

  if $::stacktach::htpasswd_file {
    apache::mod { 'authn_core': }
    $directory = {
      path           => '/',
      provider       => 'location',
      auth_name      => 'StackTach',
      auth_type      => 'Basic',
      auth_user_file => $::stacktach::htpasswd_file,
      require        => 'valid-user',
    }
  } else {
    $directory = undef
  }


  # Configure apache to serve stacktach as the default iste
  apache::vhost { $::fqdn:
    port                         => 80,
    docroot                      => '/var/www',
    default_vhost                => true,
    wsgi_application_group       => '%{GLOBAL}',
    wsgi_process_group           => 'wsgi',
    wsgi_daemon_process          => 'wsgi',
    wsgi_daemon_process_options  => {
      processes    => '2',
      threads      => '15',
      display-name => '%{GROUP}',
    },
    wsgi_import_script  => "${::stacktach::install_dir}/app/wsgi.py",
    wsgi_import_script_options  => {
      process-group => 'wsgi',
      application-group => '%{GLOBAL}'
    },
    wsgi_script_aliases => { '/' => "${::stacktach::install_dir}/app/wsgi.py" },

    aliases => {
      alias => '/static/',
      path  => "${::stacktach::install_dir}/app/static/",
    },
    directories => $directory,
  }

}
