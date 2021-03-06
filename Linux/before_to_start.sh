#!/bin/bash

# description
# Initialisation before to start from a clone or a template

#-----------------------#
#	Functions	#
#-----------------------#

update () {

	echo "Update packages"
	apt update
	apt upgrade -y
	apt autoremove -y

	echo "Installating VMware tools & sudo"
	apt install open-vm-tools sudo -y
}

create_an_user () {
	read -p 'write your NEW username : ' username

#	Creating new user and /home
# 	Info:	useradd is native binary compiled with the system / adduser is a perl script which uses useradd binary in back-end
	sudo useradd $username --create-home --home /home/$username --groups sudo --shell /bin/bash

#	Creating new user's password
	passwd $username
}

change_hostname () {
#	Get old hostname
	old=$(hostname)

#	New hostname fulfilled by user
	read -p 'your new hostname : ' hostname
	hostnamectl set-hostname $hostname

#	Modifying "hostname.domain" and "hostname" at the second line
	grep -w $old /etc/hosts | sed -i "2s/$old/$hostname/g" /etc/hosts
}

check_net_int_conf_file () {
#	For Debian
	if [ $(cat /etc/os-release | grep -w ID | cut -d "=" -f2) == debian ] ; then
		grep -quiet allow-hotplug /etc/network/interfaces 2> /dev/null
		if	[[ $(echo $?) -eq 0 ]] ; then
			sed -i 's/allow-hotplug/auto/' /etc/network/interfaces
		fi
	fi
}

pwd_root () {
	if 	[[ $UID -ne 0 || $(pwd) != "/root" ]] ; then
		echo "Run :"
		echo "su root"
		echo "mv $(basename $0) -t /root/ && cd"
		exit 1
	fi
}

#-------------------#
#	Start	    #
#-------------------#

pwd_root

update

create_an_user

echo "Root password :"
passwd

change_hostname

check_net_int_conf_file

echo "'logout' to use your new login : $username"
