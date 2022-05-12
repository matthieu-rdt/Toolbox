#!/bin/bash

# description
# generating a passphrase (if needed) then a SSH key pair with a send to the remote server

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

read -p 'give your ssh key a name :' keyname

echo "The script suggests one of the encryption algorithms below"
echo "RSA | ECDSA | ED25519" && sleep 2

ConfirmChoice "RSA , Proven and recommended with a key size of 4096 bits. Compatible everywhere" && ssh-keygen -b 4096 -f ~/.ssh/$keyname # by default so no need for "-type"

ConfirmChoice "ECDSA , Advised by the ANSSI but a priori not trusted by everyone" && ssh-keygen -t $b -b 521 -f ~/.ssh/$keyname

ConfirmChoice "ED25519 , The latest and greatest in terms of safety and performance" && ssh-keygen -t $c -f ~/.ssh/$keyname

read -p 'Type the address of the remote server in this form: (example: 192.168.0.20)' address 

read -p 'Type in the remote server login - this is the server user:' login

#	Checking the data entered by the client
echo "your login and IP address are: $login@$address"

#	Send the public key to the desired server
ssh-copy-id -i ~/.ssh/$keyname.pub $login@$address

echo "You can now connect to the server with your login and your server IP address" 
