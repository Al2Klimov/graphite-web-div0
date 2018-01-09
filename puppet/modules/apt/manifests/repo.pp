define apt::repo ($deb, $debsrc) {
	file { "/etc/apt/sources.list.d/${name}.list":
		content => "deb ${deb}
deb-src ${debsrc}
",
		notify  => Exec["apt update # ${name}"],
	}

	exec { "apt update # ${name}":
		command     => '/usr/bin/apt update',
		refreshonly => true,
	}
}
