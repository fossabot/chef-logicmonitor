name 'logicmonitor'
maintainer 'Granicus'
maintainer_email 'mattk@granicus.com'
license 'apachev2'
description 'Installs/Configures logicmonitor'
long_description 'Installs/Configures logicmonitor'
version '0.1.2'

%w( aix amazon centos fedora freebsd debian oracle mac_os_x redhat suse opensuse opensuseleap ubuntu windows zlinux ).each do |os|
  supports os
end

issues_url 'https://github.com/Granicus/chef-logicmonitor/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Granicus/chef-logicmonitor' if respond_to?(:source_url)
chef_version '>= 12.11'
