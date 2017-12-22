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
}
