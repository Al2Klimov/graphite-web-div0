node default {
	include graphite
	include icinga::master
	include icinga::web

	package { 'mariadb-server':
	}
	-> package { 'icinga2-ido-mysql':
		require => Class['icinga::pkgrepo'],
	}

	exec { 'mysql-grant-icinga2':
		command     => '/usr/bin/mysql -e "GRANT ALL ON icinga2.* to icinga2@\'localhost\' IDENTIFIED BY \'icinga2\';"',
		subscribe   => Package['icinga2-ido-mysql'],
		refreshonly => true,
	}
	-> icinga::feature { 'ido-mysql':
		config => file('site_files/etc/icinga2/features-available/ido-mysql.conf'),
	}

	icinga::feature { 'graphite':
		config  => file('site_files/etc/icinga2/features-available/graphite.conf'),
		require => Class['graphite'],
	}

	file { '/etc/icinga2/zones.conf':
		source  => 'puppet:///modules/site_files/etc/icinga2/zones.conf',
		require => Package['icinga2-bin'],
	}
	-> file { '/etc/icinga2/zones.d/MSEDGEWIN10':
		ensure => directory,
	}
	-> file { '/etc/icinga2/zones.d/MSEDGEWIN10/MSEDGEWIN10.conf':
		source => 'puppet:///modules/site_files/etc/icinga2/zones.d/MSEDGEWIN10/MSEDGEWIN10.conf',
		notify => Service['icinga2'],
	}

	file { '/etc/icinga2/conf.d/api-users.conf':
		source  => 'puppet:///modules/site_files/etc/icinga2/conf.d/api-users.conf',
		require => Package['icinga2-bin'],
		notify  => Service['icinga2'],
	}

	git::repo { '/usr/share/icingaweb2/modules/graphite':
		clone    => 'https://github.com/Icinga/icingaweb2-module-graphite.git',
		checkout => 'd012b74fb2b7a2614956637a2bae43747a1f97c8',
		require  => Class['icinga::web'],
	}

	file { '/etc/apache2/conf-available/icingaweb2-fakeauth.conf':
		source  => 'puppet:///modules/site_files/etc/apache2/conf-available/icingaweb2-fakeauth.conf',
		require => [
			Package['apache2'],
			File[[
				'/etc/icingaweb2/authentication.ini',
				'/etc/icingaweb2/config.ini',
				'/etc/icingaweb2/roles.ini'
			]]
		]
	}
	-> file { '/etc/apache2/conf-enabled/icingaweb2-fakeauth.conf':
		ensure  => link,
		target  => '/etc/apache2/conf-available/icingaweb2-fakeauth.conf',
		notify  => Service['apache2'],
	}

	file { '/etc/icingaweb2':
		ensure  => directory,
		purge   => true,
		recurse => true,
		force   => true,
		require => Class['icinga::web'],
	}

	file { '/etc/icingaweb2/authentication.ini':
		source  => 'puppet:///modules/site_files/etc/icingaweb2/authentication.ini',

		require => File['/etc/icingaweb2'],
	}

	file { '/etc/icingaweb2/config.ini':
		source  => 'puppet:///modules/site_files/etc/icingaweb2/config.ini',
		require => File['/etc/icingaweb2'],
	}

	file { '/etc/icingaweb2/resources.ini':
		source  => 'puppet:///modules/site_files/etc/icingaweb2/resources.ini',
		require => [
			File['/etc/icingaweb2'],
			Exec['mysql-grant-icinga2']
		],
	}

	file { '/etc/icingaweb2/roles.ini':
		source  => 'puppet:///modules/site_files/etc/icingaweb2/roles.ini',
		require => File['/etc/icingaweb2'],
	}

	file { '/etc/icingaweb2/modules':
		ensure  => directory,
		purge   => true,
		recurse => true,
		force   => true,
		require => File['/etc/icingaweb2'],
	}

	file { '/etc/icingaweb2/modules/monitoring':
		ensure  => directory,
		purge   => true,
		recurse => true,
		force   => true,
		require => File['/etc/icingaweb2/modules'],
	}

	file { '/etc/icingaweb2/modules/monitoring/backends.ini':
		source  => 'puppet:///modules/site_files/etc/icingaweb2/modules/monitoring/backends.ini',
		require => File[[
			'/etc/icingaweb2/modules/monitoring',
			'/etc/icingaweb2/resources.ini'
		]],
	}

	file { '/etc/icingaweb2/modules/monitoring/commandtransports.ini':
		source  => 'puppet:///modules/site_files/etc/icingaweb2/modules/monitoring/commandtransports.ini',
		require => [
			File['/etc/icingaweb2/modules/monitoring'],
			Service['icinga2']
		],
	}

	file { '/etc/icingaweb2/modules/monitoring/config.ini':
		source  => 'puppet:///modules/site_files/etc/icingaweb2/modules/monitoring/config.ini',
		require => File['/etc/icingaweb2/modules/monitoring'],
	}

	file { '/etc/icingaweb2/modules/graphite':
		ensure  => directory,
		purge   => true,
		recurse => true,
		force   => true,
		require => File['/etc/icingaweb2/modules'],
	}

	file { '/etc/icingaweb2/modules/graphite/config.ini':
		source  => 'puppet:///modules/site_files/etc/icingaweb2/modules/graphite/config.ini',
		require => [
			File['/etc/icingaweb2/modules/graphite'],
			Class['graphite']
		],
	}

	file { '/etc/icingaweb2/enabledModules':
		ensure  => directory,
		purge   => true,
		recurse => true,
		force   => true,
		require => File['/etc/icingaweb2'],
	}

	file { '/etc/icingaweb2/enabledModules/monitoring':
		ensure  => link,
		target  => '/usr/share/icingaweb2/modules/monitoring',
		require => File[[
			'/etc/icingaweb2/enabledModules',
			'/etc/icingaweb2/modules/monitoring/backends.ini',
			'/etc/icingaweb2/modules/monitoring/commandtransports.ini',
			'/etc/icingaweb2/modules/monitoring/config.ini'
		]],
	}
	-> file { '/etc/icingaweb2/enabledModules/graphite':
		ensure  => link,
		target  => '/usr/share/icingaweb2/modules/graphite',
		require => [
			File[[
				'/etc/icingaweb2/enabledModules',
				'/etc/icingaweb2/modules/graphite/config.ini'
			]],
			Git::Repo['/usr/share/icingaweb2/modules/graphite']
		],
	}
}
