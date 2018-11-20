# Class: unifi
class unifi (
  $download_url = 'http://dl.ubnt.com/unifi/5.9.29/UniFi.unix.zip',
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
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0744',
    source => 'puppet:///modules/puppet_unifi/unifi.service',
    notify  => [
        Exec['unifi-systemd-reload'],
        Service['unifi'],
    ],
  }

  file { $install_path:
    ensure => directory,
  }

  # Hacky way to download the dashboard
  exec { "/usr/bin/wget ${download_url} && unzip -q UniFi.unix.zip -d /opt":
    cwd         => $install_path,
    creates     => "${install_path}/tsdbrelay-linux-amd64",
    require     => File[$install_path]
  }

}
