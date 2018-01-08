define icinga::feature ($config) {
	include icinga::abstract

	file { "/etc/icinga2/features-available/${name}.conf":
		content => $config,
		require => Package['icinga2-bin'],
	}
	-> file { "/etc/icinga2/features-enabled/${name}.conf":
		ensure => link,
		target => "/etc/icinga2/features-available/${name}.conf",
		notify => Service['icinga2'],
	}
}
