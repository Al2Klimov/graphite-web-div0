class icinga::abstract {
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
}
