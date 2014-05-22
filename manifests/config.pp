#
# Class rabbitmq::config
#
class rabbitmq::config(
  $port         = 5672,
  $ssl_port     = 5671,
  $key_path     = undef,
  $cert_path    = undef,
  $ca_cert_path = undef,
  $mnesia_base  = '/var/lib/rabbitmq',
  $log_base     = '/var/log/rabbitmq',
  $user_name    = 'guest',
  $password     = 'guest',
  $node_name    = 'rabbit@localhost',
) {
  
  File {
    ensure => present,
    owner  => "rabbitmq",
    group  => "rabbitmq",
  }
  
  exec { 'rabbitmq-stop':
    command   => 'service rabbitmq-server stop;',
    path      => '/sbin/:/usr/sbin/:/usr/bin/:/bin/',
    logoutput => true,
  }
  
  file { $mnesia_base:
    ensure  => directory,
    mode    => 0755,
    require => Exec['rabbitmq-stop'],
  }
  
  file { "${mnesia_base}/mnesia":
    ensure  => directory,
    mode    => 0755,
    require => File["$mnesia_base"],
  }
  
  file { "$log_base":
    ensure  => directory,
    mode    => 0755,
    require => Exec['rabbitmq-stop'],
  }
  
  file { '/etc/rabbitmq/rabbitmq-env.conf':
    content => template('rabbitmq/rabbitmq-env.conf.erb'),
    require => [File["${mnesia_base}/mnesia"],File["$log_base"]],
  }
  
  file { '/etc/rabbitmq/rabbitmq.config':
    content => template('rabbitmq/rabbitmq.config.erb'),
    require => File['/etc/rabbitmq/rabbitmq-env.conf'],
  }
  
  exec { 'rabbitmq-start':
    command   => 'service rabbitmq-server start',
    path      => '/sbin/:/usr/sbin/:/usr/bin/:/bin/',
    logoutput => true,
    require   => File['/etc/rabbitmq/rabbitmq.config'],
  }  
  
}
