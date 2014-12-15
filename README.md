puppet-stacktach
================
Puppet module for [OpenStack StackTach](https://github.com/rackerlabs/stacktach) and [stacky](https://github.com/rackerlabs/stacky).

Requirements
------------
* [puppet-python](https://github.com/stankevich/puppet-python)
* [puppet-apache](https://github.com/puppetlabs/puppetlabs-mysql)
* [puppet-mysql](https://github.com/puppetlabs/puppetlabs-mysql)
* [puppet-hash2json](https://github.com/jtopjian/puppet-hash2json)

Example
-------

### Hiera

```yaml
stacktach::mysql::password: 'password'
stacktach::django::config:
  STACKTACH_DB_ENGINE: 'django.db.backends.mysql'
  STACKTACH_DB_HOST: '192.168.255.10'
  STACKTACH_DB_PORT: '3306'
  STACKTACH_DB_NAME: 'stacktach'
  STACKTACH_DB_USERNAME: 'stacktach'
  STACKTACH_DB_PASSWORD: "%{hiera('stacktach::mysql::password')}"
  STACKTACH_INSTALL_DIR: '/opt/stacktach/app/'
  STACKTACH_DEPLOYMENTS_FILE: '/opt/stacktach/app/etc/stacktach_worker_config.json'
  STACKTACH_VERIFIER_CONFIG: '/opt/stacktach/app/etc/stacktach_verifier_config.json'
  DJANGO_SETTINGS_MODULE: 'settings'
stacktach::verifier::config:
  tick_time: 30
  settle_time: 5
  settle_units: 'minutes'
  pool_size: 2
  enable_notifications: true
  validation_level: 'all'
  flavor_field_name: 'instance_type_id'
  rabbit:
    durable_queue: false
    host: "%{hiera('openstack::cloud_controller')}"
    port: 5672
    userid: "%{hiera('openstack::rabbitmq::userid')}"
    password: "%{hiera('openstack::rabbitmq::password')}"
    virtual_host: '/'
    topics:
      nova: ["notifications.info"]
      glance: ["notifications.info"]
stacktach::worker::config:
  deployments:
    - name: "%{hiera('openstack::region')}"
      durable_queue: false
      rabbit_host: "%{hiera('openstack::cloud_controller')}"
      rabbit_port: 5672
      rabbit_userid: "%{hiera('openstack::rabbitmq::userid')}"
      rabbit_password: "%{hiera('openstack::rabbitmq::password')}"
      rabbit_virtual_host: '/'
      exit_on_exception: true
      queue_name: 'stacktach'
      topics:
        nova:
          - queue: 'monitor.info'
            routing_key: 'monitor.info'
          - queue: 'monitor.error'
            routing_key: 'monitor.error'
        glance:
          - queue: 'stacktach_monitor_glance.info'
            routing_key: 'monitor_glance.info'
          - queue: 'stacktach_monitor_glance.error'
            routing_key: 'monitor_glance.error'
```

### Puppet

```puppet
class site::profiles::stacktach {
  class { '::apache': } ->
  class { 'site::profiles::mysql::server': } ->
  class { '::stacktach::db::mysql':
    db_password => hiera('stacktach::mysql::password'),
  } ->
  class { '::stacktach':
    django_config   => hiera('stacktach::django::config'),
    verifier_config => hiera('stacktach::verifier::config'),
    worker_config   => hiera('stacktach::worker::config'),
  }
}
```
