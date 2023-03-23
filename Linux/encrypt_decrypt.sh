#!/bin/bash

# Usage 1
# ./encrypt_decrypt.sh -m enc -s "StringYouWantToEncrypt"

# Usage 2
# ./encrypt_decrypt.sh -m enc -s "StringYouWantToDecrypt"

# Get the parameteres of the script and assign them
while getopts m:s:p: flag
do
	case "${flag}" in
		m) mechanism=${OPTARG};;
		s) string=${OPTARG};;
		p) password=${OPTARG};;
	esac
done

# Check if all parameters are set, if not show an error message and exit the script
if	[ -z "$mechanism" ] || [ -z "$string" ] ; then
	echo "You need to set all variables to run the script: -m enc for encryption or dec for decryption, -s The string to encrypt/decrypt, -p The password for the encryption/decryption"
	exit 10
fi

# If the mechanism is encryption => encrypt the string, if the mechanism is decryption => decrypt the string
if	[ $mechanism == 'enc' ] ; then
	read -sp 'Your password ' password
	echo $string | openssl enc -base64 -e -aes-256-cbc -salt -pass pass:$password -pbkdf2

elif	[ $mechanism == 'dec' ] ; then
	read -sp 'Your password ' password
	echo $string | openssl enc -base64 -d -aes-256-cbc -salt -pass pass:$password -pbkdf2

else
	echo "Mechanism (-m) must be enc for encryption or dec for decryption"
fi
