class icinga::master {
	include icinga::abstract

	exec { "/usr/sbin/icinga2 node setup --master --zone '${::hostname}' --listen 0.0.0.0,5665":
		creates => '/var/lib/icinga2/ca/ca.crt',
		require => Package['icinga2-bin'],
		notify  => Service['icinga2'],
	}
}
