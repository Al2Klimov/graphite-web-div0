class graphite {
	if (!defined(Package['apache2'])) {
		package { 'apache2':
		}
	}

	if (!defined(Package['gcc'])) {
		package { 'gcc':
		}
	}

	if (!defined(Package['libapache2-mod-wsgi'])) {
		package { 'libapache2-mod-wsgi':
			notify => Service['apache2'],
		}
	}

	if (!defined(Package['libcairo2'])) {
		package { 'libcairo2':
		}
	}

	if (!defined(Package['libffi-dev'])) {
		package { 'libffi-dev':
		}
	}

	if (!defined(Package['python'])) {
		package { 'python':
		}
	}

	if (!defined(Package['python-dev'])) {
		package { 'python-dev':
		}
	}

	if (!defined(Package['virtualenv'])) {
		package { 'virtualenv':
		}
	}

	if (!defined(Service['apache2'])) {
		service { 'apache2':
			ensure  => running,
			enable  => true,
			require => Package['apache2'],
		}
	}

	group { 'graphite':
		ensure => present,
	}
	-> user { 'graphite':
		ensure => present,
		gid    => 'graphite',
		home   => '/opt/graphite/home',
	}
	-> file { '/opt/graphite':
		ensure => directory,
		owner  => 'graphite',
		group  => 'graphite',
	}

	exec { '/usr/bin/virtualenv /opt/graphite':
		user        => 'graphite',
		group       => 'graphite',
		require     => Package[['virtualenv', 'python']],
		subscribe   => File['/opt/graphite'],
		refreshonly => true,
	}
	-> file { '/opt/graphite/home':
		ensure => directory,
		owner  => 'graphite',
		group  => 'graphite',
	}

	$activateVEnv = '. /opt/graphite/bin/activate'
	$pyPath = 'PYTHONPATH=/opt/graphite/lib/:/opt/graphite/webapp/'

	define pip_install_graphite ($prefix) {
		exec { "${prefix} /opt/graphite/bin/pip install --no-binary=:all: https://github.com/graphite-project/${name}/tarball/master":
			user     => 'graphite',
			group    => 'graphite',
			provider => shell,
			require  => File['/opt/graphite/home'],
		}
	}

	Graphite::Pip_install_graphite {
		prefix => "${activateVEnv} ; ${pyPath}",
	}

	pip_install_graphite { 'whisper':
	}
	-> pip_install_graphite { 'carbon':
		require => Package[['gcc', 'python-dev']],
	}
	-> pip_install_graphite { 'graphite-web':
		require => Package[['gcc', 'libffi-dev', 'libcairo2']],
	}

	file { '/opt/graphite/conf/aggregation-rules.conf':
		source  => 'file:///opt/graphite/conf/aggregation-rules.conf.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	file { '/opt/graphite/conf/blacklist.conf':
		source  => 'file:///opt/graphite/conf/blacklist.conf.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	file { '/opt/graphite/conf/carbon.amqp.conf':
		source  => 'file:///opt/graphite/conf/carbon.amqp.conf.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	file { '/opt/graphite/conf/carbon.conf':
		source  => 'file:///opt/graphite/conf/carbon.conf.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	file { '/opt/graphite/conf/dashboard.conf':
		source  => 'file:///opt/graphite/conf/dashboard.conf.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	file { '/opt/graphite/conf/graphite.wsgi':
		source  => 'file:///opt/graphite/conf/graphite.wsgi.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	file { '/opt/graphite/conf/graphTemplates.conf':
		source  => 'file:///opt/graphite/conf/graphTemplates.conf.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	file { '/opt/graphite/conf/relay-rules.conf':
		source  => 'file:///opt/graphite/conf/relay-rules.conf.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	file { '/opt/graphite/conf/rewrite-rules.conf':
		source  => 'file:///opt/graphite/conf/rewrite-rules.conf.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	file { '/opt/graphite/conf/storage-aggregation.conf':
		source  => 'file:///opt/graphite/conf/storage-aggregation.conf.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	file { '/opt/graphite/conf/storage-schemas.conf':
		source  => 'file:///opt/graphite/conf/storage-schemas.conf.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	file { '/opt/graphite/conf/whitelist.conf':
		source  => 'file:///opt/graphite/conf/whitelist.conf.example',
		owner   => 'graphite',
		group   => 'graphite',
		require => Graphite::Pip_install_graphite[['whisper', 'carbon', 'graphite-web']],
	}

	exec { "${activateVEnv} ; ${pyPath} /opt/graphite/bin/django-admin migrate --settings=graphite.settings":
		user     => 'graphite',
		group    => 'graphite',
		provider => shell,
		require  => File[[
			'/opt/graphite/conf/aggregation-rules.conf',
			'/opt/graphite/conf/blacklist.conf',
			'/opt/graphite/conf/carbon.amqp.conf',
			'/opt/graphite/conf/carbon.conf',
			'/opt/graphite/conf/dashboard.conf',
			'/opt/graphite/conf/graphite.wsgi',
			'/opt/graphite/conf/graphTemplates.conf',
			'/opt/graphite/conf/relay-rules.conf',
			'/opt/graphite/conf/rewrite-rules.conf',
			'/opt/graphite/conf/storage-aggregation.conf',
			'/opt/graphite/conf/storage-schemas.conf',
			'/opt/graphite/conf/whitelist.conf'
		]],
	}
	-> file { '/etc/apache2/conf-available/graphite.conf':
		source  => 'puppet:///modules/graphite/etc/apache2/conf-available/graphite.conf',
		require => Package[['apache2', 'libapache2-mod-wsgi']],
	}
	-> file { '/etc/apache2/conf-enabled/graphite.conf':
		ensure => link,
		target => '/etc/apache2/conf-available/graphite.conf',
		notify => Service['apache2'],
	}

	file { '/etc/systemd/system/carbon-cache.service':
		source => 'puppet:///modules/graphite/etc/systemd/system/carbon-cache.service',
		require  => File[[
			'/opt/graphite/conf/aggregation-rules.conf',
			'/opt/graphite/conf/blacklist.conf',
			'/opt/graphite/conf/carbon.amqp.conf',
			'/opt/graphite/conf/carbon.conf',
			'/opt/graphite/conf/dashboard.conf',
			'/opt/graphite/conf/graphite.wsgi',
			'/opt/graphite/conf/graphTemplates.conf',
			'/opt/graphite/conf/relay-rules.conf',
			'/opt/graphite/conf/rewrite-rules.conf',
			'/opt/graphite/conf/storage-aggregation.conf',
			'/opt/graphite/conf/storage-schemas.conf',
			'/opt/graphite/conf/whitelist.conf'
		]],
	}

	exec { '/bin/systemctl daemon-reload # carbon-cache':
		command     => '/bin/systemctl daemon-reload',
		subscribe   => File['/etc/systemd/system/carbon-cache.service'],
		refreshonly => true,
	}
	-> service { 'carbon-cache':
		ensure => running,
		enable => true,
	}
}
