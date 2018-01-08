class icinga::web {
	if (!defined(Apt::Key['https://packages.icinga.com/icinga.key'])) {
		apt::key { 'https://packages.icinga.com/icinga.key':
		}
	}

	if (!defined(Apt::Repo['packages.icinga.com'])) {
		apt::repo { 'packages.icinga.com':
			deb     => 'http://packages.icinga.com/ubuntu icinga-xenial main',
			debsrc  => 'http://packages.icinga.com/ubuntu icinga-xenial main',
			require => Apt::Key['https://packages.icinga.com/icinga.key'],
		}
	}

	package { 'icingaweb2':
		require => Apt::Repo['packages.icinga.com'],
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
