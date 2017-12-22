node default {
	include graphite
	include icinga::web

	git::repo { '/usr/share/icingaweb2/modules/graphite':
		clone    => 'https://github.com/Icinga/icingaweb2-module-graphite.git',
		checkout => 'd012b74fb2b7a2614956637a2bae43747a1f97c8',
		require  => Class['icinga::web'],
	}
}
