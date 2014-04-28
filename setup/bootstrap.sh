#! /bin/bash

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR='/vagrant/setup/puppet'
PUPPET_MANIFEST='default.pp'
PATH=$PATH:/opt/ruby/bin/

# NB: librarian-puppet might need git installed. If it is not already installed
# in your basebox, this will manually install it at this point using apt or yum
GIT=/usr/bin/git
APT_GET=/usr/bin/apt-get
YUM=/usr/sbin/yum

if [ -x $APT_GET ]; then
	/bin/bash -c 'exit $(( $(( $(date +%s) - $(stat -c %Y /var/lib/apt/lists/$( ls /var/lib/apt/lists/ -tr1|tail -1 )) )) <= 604800 ))'
	apt_out_of_date=$?
	#Makes sure that puppet is up to date
	if [ ! -e "/tmp/puppetlabs-release-precise.deb" ]; then
		wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb -O /tmp/puppetlabs-release-precise.deb
		dpkg -i /tmp/puppetlabs-release-precise.deb
	fi
	#Makes sure that aptitude is up to date
	if [ "$apt_out_of_date" -eq "0" ]; then
		apt-get update
	fi
	#Installs the newest puppet common stuff and ruby dev (should be already present)
	apt-get install -y puppet-common ruby-dev
fi

#Make sure we have git
if [ ! -x $GIT ]; then
    if [ -x $YUM ]; then
        yum -q -y install git-core
    elif [ -x $APT_GET ]; then
        apt-get -q -y install git-core
    else
        echo "No package installer available. You may need to install git manually."
    fi
fi

#Install librarian-puppet
if [ `gem query --local | grep librarian-puppet | wc -l` -eq 0 ]; then
  gem install librarian-puppet
fi
cd $PUPPET_DIR
#Makes sure that librarian uses the VM's filesystem, not yours, or you end up with pathing issues
LIBRARIAN_PUPPET_TMP=/tmp/puppet librarian-puppet install --path=/usr/share/puppet/modules
#Gets the full module path of normal modules
MOD_PATH=`puppet config print | grep "modulepath = " | awk '{print $3}'`
# now we run puppet, and we include the local mod path, just in case
puppet apply -vv --modulepath=$MOD_PATH:$PUPPET_DIR/modules $PUPPET_DIR/manifests/$PUPPET_MANIFEST
