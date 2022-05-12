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

if [ ! -d .ssh ] ; then
	mkdir ~/.ssh
fi

#	Creating a secure passphrase
echo "Choose if you prefer a 128 bits OR a 256 bits passphrase" && sleep 2

ConfirmChoice "Generate a passphrase with 128 bits of entropy ?" && passwd=`dd if=/dev/urandom bs=16 count=1 2>/dev/null | base64 | sed 's/=//g'`
echo $passwd > $HOME/passph.txt

ConfirmChoice "Generate a passphrase with 256 bits of entropy ?" && passwd=`dd if=/dev/urandom bs=32 count=1 2>/dev/null | sha256sum -b | sed 's/ .*//'`
echo $passwd > $HOME/passph.txt

chmod 400 $HOME/passph.txt && echo "Your passphrase is located in $HOME/passph.txt"

##	Generation of a public/private key pair
#	Encryption algorithms

read -p 'give your ssh key a name : ' keyname

echo "The script suggests one of the encryption algorithms below"
echo "RSA | ED25519" && sleep 2

ConfirmChoice "RSA , Proven and recommended with a key size of 4096 bits. Compatible everywhere" && ssh-keygen -a 100 -b 4096 -N "$passwd" -f ~/.ssh/$keyname # by default so no need for "-t"

ConfirmChoice "ED25519 , The latest and greatest in terms of safety and performance" && ssh-keygen -a 100 -f ~/.ssh/$keyname -N "$passwd" -t ed25519

read -p 'Type the address of the remote server in this form: (example: 192.168.0.20) ' address 

read -p 'Type in the remote server login - this is the server user: ' login

#	Checking the data entered by the client
echo "your login and IP address are: $login@$address"

#	Send the public key to the desired server
ssh-copy-id -i ~/.ssh/$keyname.pub $login@$address

# To finish
#tee -a ~/.ssh/config << END
#Host $
#	HostName $IP
#	User $login
#	IdentityFile ~/.ssh/$keyname
#	IdentitiesOnly yes
#END
