#!/bin/bash

# description
# generating a passphrase (if needed) then a SSH key pair with a send to the remote server
# ssh-keygen [-q] [-a rounds] [-b bits] [-C comment] [-f output_keyfile] [-m format] [-N new_passphrase] [-O option] [-t dsa | ecdsa | ecdsa-sk | ed25519 | ed25519-sk | rsa]

#-----------------------#
#	Functions	#
#-----------------------#

# Function from Manu
function ConfirmChoice() 
{
	ConfYorN="";
		while [ "${ConfYorN}" != "y" -a "${ConfYorN}" != "Y" -a "${ConfYorN}" != "n" -a "${ConfYorN}" != "N" ]
		do
			echo -n $1 "(y/n) : "
			read ConfYorN
		done
	[ "${ConfYorN}" == "y" -o "${ConfYorN}" == "Y" ] && return 0 || return 1
}

#-------------------#
#	Start	    #
#-------------------#

if	[ ! -d .ssh ] ; then
	mkdir ~/.ssh
fi

#	Using an existing passphrase
ConfirmChoice "Do you have a passphrase to use" && read -s passwd

#	Creating a secure passphrase if needed
ConfirmChoice "Generate a passphrase with 128 bits of entropy ?" && passwd=`dd if=/dev/urandom bs=16 count=1 2>/dev/null | base64 | sed 's/=//g'` \
echo $passwd > $HOME/passph.txt

ConfirmChoice "Generate a passphrase with 256 bits of entropy ?" && passwd=`dd if=/dev/urandom bs=32 count=1 2>/dev/null | sha256sum -b | sed 's/ .*//'` \
echo $passwd > $HOME/passph.txt

chmod 400 $HOME/passph.txt && echo "Your passphrase is located in $HOME/passph.txt"

##	Generation of a public/private key pair
#	Encryption algorithms

ConfirmChoice "Do you want to name your key" && read -p 'give your ssh key a name : ' keyname

echo "One of the encryption algorithms is recommended"
echo "RSA | ED25519" && sleep 2

if 	[ -f "$passwd" ] ; then
	ConfirmChoice "RSA , Proven and recommended with a key size of 4096 bits. Compatible everywhere" && ssh-keygen -a 100 -b 4096 -N "$passwd" -f ~/.ssh/$keyname # by default so no need for "-t"

	ConfirmChoice "ED25519 , The latest and greatest in terms of safety and performance" && ssh-keygen -a 100 -f ~/.ssh/$keyname -N "$passwd" -t ed25519

else
#	by default so no need for "-t"
	ConfirmChoice "RSA , Proven and recommended with a key size of 4096 bits. Compatible everywhere" && ssh-keygen -a 100 -b 4096 -f ~/.ssh/$keyname

	ConfirmChoice "ED25519 , The latest and greatest in terms of safety and performance" && ssh-keygen -a 100 -f ~/.ssh/$keyname -t ed25519
fi

read -p 'Type the address of the remote server in this form: (example: 192.168.1.2) ' address

read -p 'Type in the remote server login - this is the server user : ' login

#	Checking the data entered by the client
echo "your login and IP address are: $login@$address"

#	Send the public key to the desired server
ssh-copy-id -i ~/.ssh/$keyname.pub $login@$address

#	Make SSH connection easier
echo "Creating ~/.ssh/config"
echo "Usage ssh <customised hostname>"

read -p 'Name your machine : ' hostname

tee -a ~/.ssh/config << END
Host $hostname
	HostName $address
	User $login
	IdentityFile ~/.ssh/$keyname
	IdentitiesOnly yes
END
