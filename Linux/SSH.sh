#!/bin/bash

# description
# generating a passphrase (if needed) then a SSH key pair with a send to the remote server
# ssh-keygen [-q] [-a rounds] [-b bits] [-C comment] [-f output_keyfile] [-m format] [-N new_passphrase] [-O option] [-t dsa | ecdsa | ecdsa-sk | ed25519 | ed25519-sk | rsa]


#-----------------------#
#	Functions	#
#-----------------------#

# Function from Manu
ConfirmChoice ()
{
	ConfYorN="";
	while [ "${ConfYorN}" != "y" ] && [ "${ConfYorN}" != "Y" ] && [ "${ConfYorN}" != "n" ] && [ "${ConfYorN}" != "N" ]
	do
		echo -n "$1" "(y/n) : "
		read ConfYorN
	done
	[ "${ConfYorN}" == "y" ] || [ "${ConfYorN}" == "Y" ] && return 0 || return 1
}

CreatePassphrase ()
{
	#	Creating a secure passphrase if needed
	ConfirmChoice "Generate a passphrase with 128 bits of entropy ?" && passwd=$(dd if=/dev/urandom bs=16 count=1 2>/dev/null | base64 | sed 's/=//g')
	ConfirmChoice "Generate a passphrase with 256 bits of entropy ?" && passwd=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | sha256sum -b | sed 's/ .*//')
}

Permissions ()
{
	chmod 600 ~/.ssh/authorized_keys
	chmod 600 ~/.ssh/config
	chmod 644 ~/.ssh/*.pub
	chmod 700 ~/.ssh/
	chmod 755 $HOME
}

File_sshd ()
{
        grep -q 'PermitRootLogin yes' /etc/ssh/sshd_config
        if      [ $? -eq 1 ] ; then
                sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config || \
                sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
                systemctl restart ssh
                systemctl restart sshd
        else
                sed -i 's/PermitRootLogin yes/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
                systemctl restart ssh
                systemctl restart sshd
        fi
}

#-------------------#
#	Start	    #
#-------------------#

if	[ ! -d ~/.ssh ] ; then
	mkdir ~/.ssh
fi

#	Enable PermitRootLogin
	File_sshd

#	Using an existing passphrase
ConfirmChoice "Do you want to use a passphrase" && read -sp 'Your passphrase : ' passwd || CreatePassphrase

while	[ -z "$keyname" ] ; do
	echo "Note : If the key name is already existing, you can choose to overwrite it or not"
	echo "Default name is either <id_rsa> or <id_ed25519>, a name is required"
	read -p 'Give your ssh key a name : ' keyname
done

#---------------------------
passph="passph-$keyname.txt"
#---------------------------

##	Generation of a public/private key pair
#	Encryption algorithms

echo "One of these encryption algorithms is recommended"
echo "RSA | ED25519" && sleep 2

if	[ -n "$passwd" ] ; then
	echo "$passwd" > "$HOME"/"$passph" && chmod 400 "$HOME"/"$passph" ; echo "Your passphrase is located in $HOME/$passph"

	# by default so no need for "-t"
	ConfirmChoice "RSA , Proven and recommended with a key size of 4096 bits. Compatible everywhere" && ssh-keygen -a 100 -b 4096 -N "$passwd" -f ~/.ssh/"$keyname"

	ConfirmChoice "ED25519 , The latest and greatest in terms of safety and performance" && ssh-keygen -a 100 -f ~/.ssh/"$keyname" -N "$passwd" -t ed25519

else
#	by default so no need for "-t"
	ConfirmChoice "RSA , Proven and recommended with a key size of 4096 bits. Compatible everywhere" && ssh-keygen -a 100 -b 4096 -f ~/.ssh/"$keyname"

	ConfirmChoice "ED25519 , The latest and greatest in terms of safety and performance" && ssh-keygen -a 100 -f ~/.ssh/"$keyname" -t ed25519
fi

if	[ ! -f ~/.ssh/"$keyname" ] ; then
	echo 'No key pair created'
	exit 3
fi

read -p 'Type the address of the remote server in this form: (example: 192.168.1.2) ' address
ConfirmChoice "Use the current session user ($(whoami)) ?" && login=$(whoami) || \
read -p 'Type in the remote server login - this is the server user : ' login

#	Checking the data entered by the client
echo "your login and IP address are: $login@$address"

#	Send the public key to the desired server
ssh-copy-id -i ~/.ssh/"$keyname".pub "$login"@"$address"

#	Make SSH connection easier
echo "Creating ~/.ssh/config"
echo "Usage ssh <customised hostname>"

read -p 'Name your machine : ' hostname

tee -a ~/.ssh/config << END
Host $hostname
	HostName $address
	User $login
	IdentityFile ~/.ssh/$keyname
END

#	Disable PermitRootLogin
	File_sshd
