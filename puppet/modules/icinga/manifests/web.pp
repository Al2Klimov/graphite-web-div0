class icinga::web {
	include icinga::pkgrepo

	package { 'icingaweb2':
		require => Class['icinga::pkgrepo'],
	}

	file { '/etc/apache2/mods-enabled/proxy.load':
		ensure  => link,
		target  => '/etc/apache2/mods-available/proxy.load',
		require => Package[['apache2', 'icingaweb2']],
	}
	-> file { '/etc/apache2/mods-enabled/proxy_fcgi.load':
		ensure => link,
		target => '/etc/apache2/mods-available/proxy_fcgi.load',
	}
	-> file { '/etc/apache2/conf-enabled/php7.0-fpm.conf':
		ensure => link,
		target => '/etc/apache2/conf-available/php7.0-fpm.conf',
		notify => Service['apache2'],
	}
}
