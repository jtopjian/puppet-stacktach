puppet-stacktach
================
Puppet module for [OpenStack StackTach](https://github.com/rackspace/stacktach).

Example
-------

```puppet
# Base stacktach manifest
class { 'stacktach': 
  db_password => 'stacktach',
}

# Configure stacktach to use Apache/Django
class { 'stacktach::apache': }

# Configure the stacktach workers processes
class { 'stacktach::workers': }

# Add a deployment
stacktach::deployment { 'my-cloud':
  rabbit_host         => '192.168.1.1',
  rabbit_userid       => 'nova',
  rabbit_password     => 'password',
}
```
