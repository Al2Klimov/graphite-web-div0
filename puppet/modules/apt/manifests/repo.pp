define apt::repo ($deb, $debsrc) {
	if (!defined(Exec['/usr/bin/apt update'])) {
		exec { '/usr/bin/apt update':
			refreshonly => true,
		}
	}

	file { "/etc/apt/sources.list.d/${name}.list":
		content => "deb ${deb}
deb-src ${debsrc}
",
		notify  => Exec['/usr/bin/apt update'],
	}
}
