name 'blp-nrpe'
version '2.1.0'
maintainer 'Bloomberg Finance L.P.'
maintainer_email 'chef@bloomberg.net'
license 'Apache-2.0'
description 'Installs and configures nrpe.'
long_description 'Installs and configures nrpe.'

issues_url 'https://github.com/bloomberg-cookbooks/nrpe/issues'
source_url 'https://github.com/bloomberg-cookbooks/nrpe'
chef_version '>= 12.5'

supports 'centos', '>= 6.0'
supports 'redhat', '>= 6.0'
supports 'ubuntu', '>= 12.04'
supports 'aix', '>= 7.1'
supports 'freebsd', '>= 10.1'
supports 'solaris2', '>= 5.11'

depends 'build-essential'
depends 'poise-archive', '~> 1.3'
depends 'poise-service', '~> 1.0'
