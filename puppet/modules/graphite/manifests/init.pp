class graphite {
	if (!defined(Package['apache2'])) {
		package { 'apache2':
		}
	}

	if (!defined(Package['libapache2-mod-wsgi'])) {
		package { 'libapache2-mod-wsgi':
		}
	}

	if (!defined(Package['graphite-web'])) {
		package { 'graphite-web':
		}
	}

	if (!defined(Package['graphite-carbon'])) {
		package { 'graphite-carbon':
		}
	}

	if (!defined(Service['apache2'])) {
		service { 'apache2':
			ensure  => running,
			enable  => true,
			require => Package['apache2'],
		}
	}

	file { '/etc/apache2/conf-enabled/graphite.conf':
		ensure  => link,
		target  => '/usr/share/graphite-web/apache2-graphite.conf',
		require => Package[[ 'apache2', 'libapache2-mod-wsgi', 'graphite-web' ]],
		notify  => Service['apache2'],
	}

	exec { '/usr/bin/python /usr/lib/python2.7/dist-packages/graphite/manage.py syncdb --noinput':
		user    => '_graphite',
		group   => '_graphite',
		require => Package['graphite-web'],
	}
}
