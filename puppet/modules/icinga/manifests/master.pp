class icinga::master {
	include icinga::pkgrepo

	package { 'icinga2-bin':
		require => Class['icinga::pkgrepo'],
	}
	-> service { 'icinga2':
		ensure => running,
		enable => true,
	}

	file { '/etc/icinga2/conf.d':
		ensure  => directory,
		purge   => true,
		recurse => true,
		require => Package['icinga2-bin'],
		notify  => Service['icinga2'],
	}

	exec { "/usr/sbin/icinga2 node setup --master --zone '${::hostname}' --listen 0.0.0.0,5665":
		creates => '/var/lib/icinga2/ca/ca.crt',
		require => Package['icinga2-bin'],
		notify  => Service['icinga2'],
	}
}
