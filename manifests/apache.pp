class stacktach::apache {

  # Configure apache to serve stacktach as the default iste
  apache::vhost { $::fqdn:
    default_vhost => true,
    docroot       => '/var/www',
    proxy_pass    => [
      { 'path' => '/static', url => '!' },
      { 'path' => '/',       url => 'http://[::1]:8000/' },
    ],
    aliases       => [
      { alias => '/static', path => "${::stacktach::install_dir}/app/static" }
    ]
  }

}
