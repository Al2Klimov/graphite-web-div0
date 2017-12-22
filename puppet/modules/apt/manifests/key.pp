define apt::key {
	if (!defined(File['/usr/local/puppet-apt-keys'])) {
		file { '/usr/local/puppet-apt-keys':
			ensure => directory,
		}
	}

	$urlHash = md5($name)
	$dlPath = "/usr/local/puppet-apt-keys/${urlHash}"

	exec { "/usr/bin/wget -O '${dlPath}' '${name}'":
		creates => $dlPath,
		require => File['/usr/local/puppet-apt-keys'],
		notify  => Exec["/usr/bin/apt-key add '${dlPath}'"],
	}

	exec { "/usr/bin/apt-key add '${dlPath}'":
		refreshonly => true,
	}
}
