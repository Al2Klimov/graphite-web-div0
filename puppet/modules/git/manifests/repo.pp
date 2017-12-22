define git::repo ($clone, $checkout = '') {
	if (!defined(Package['git'])) {
		package { 'git':
		}
	}

	exec { "/usr/bin/git clone '${clone}' '${name}'":
		creates => $name,
		require => Package['git'],
	}

	if ($checkout != '') {
		exec { "/usr/bin/git checkout '${checkout}'":
			cwd     => $name,
			require => Exec["/usr/bin/git clone '${clone}' '${name}'"]
		}
	}
}
