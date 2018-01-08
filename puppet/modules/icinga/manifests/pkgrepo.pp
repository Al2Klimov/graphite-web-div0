class icinga::pkgrepo {
	apt::key { 'https://packages.icinga.com/icinga.key':
	}
	-> apt::repo { 'packages.icinga.com':
		deb     => 'http://packages.icinga.com/ubuntu icinga-xenial main',
		debsrc  => 'http://packages.icinga.com/ubuntu icinga-xenial main',
		require => Apt::Key['https://packages.icinga.com/icinga.key'],
	}
}
