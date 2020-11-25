# Class: unifi
class unifi (
  $download_url = 'http://dl.ubnt.com/unifi/6.0.36/UniFi.unix.zip',
  $install_path = '/opt',
){

  # hack for systemctl
  exec { 'unifi-systemd-reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  # service
  service { 'unifi':
    ensure    => running,
    provider  => systemd,
    enable    => true,
    hasstatus => true,
    require   => File['/etc/systemd/system/unifi.service'],
  }

  # Systemd file
  file {'/etc/systemd/system/unifi.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0744',
    source  => 'puppet:///modules/unifi/unifi.service',
    require => Exec['install_unifi'],
    notify  => [
        Exec['unifi-systemd-reload'],
        Service['unifi'],
    ],
  }

  file { $install_path:
    ensure => directory,
  }

  # Hacky way to download the dashboard
  exec { "install_unifi":
    command     => "/usr/bin/wget ${download_url} && unzip -q UniFi.unix.zip -d /opt && chown -R ubnt:ubnt /opt/UniFi",
    cwd         => $install_path,
    creates     => "${install_path}/UniFi/conf",
    require     => File[$install_path]
  }

}
