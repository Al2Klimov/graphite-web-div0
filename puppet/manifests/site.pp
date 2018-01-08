node default {
	include graphite
	include icinga::master
	include icinga::web

	package { 'mariadb-server':
	}
	-> package { 'icinga2-ido-mysql':
	}

	exec { '/usr/bin/mysql -e "GRANT ALL ON icinga2.* to icinga2@\'localhost\' IDENTIFIED BY \'icinga2\';"':
		subscribe   => Package['icinga2-ido-mysql'],
		refreshonly => true,
	}
	-> icinga::feature { 'ido-mysql':
		config => 'library "db_ido_mysql"
object IdoMysqlConnection "ido-mysql" {
  user = "icinga2",
  password = "icinga2",
  host = "localhost",
  database = "icinga2"
}
',
	}

	icinga::feature { 'graphite':
		config  => 'library "perfdata"
object GraphiteWriter "graphite" {
  host = "127.0.0.1"
  port = 2003
}
',
		require => Class['graphite'],
	}

	git::repo { '/usr/share/icingaweb2/modules/graphite':
		clone    => 'https://github.com/Icinga/icingaweb2-module-graphite.git',
		checkout => 'd012b74fb2b7a2614956637a2bae43747a1f97c8',
		require  => Class['icinga::web'],
	}
}
