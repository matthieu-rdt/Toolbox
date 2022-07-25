#!/bin/bash

ip=172.25.161
read -p 'you are going to connect to 172.25.161.' switch
read -p 'enter the oid you wanna display ' oid

if [[ $switch  =~ ^[^0-9]+$ ]] ; then
	echo "not an ip address" 
	exit 1
elif [[ $oid =~ ^[^.iso1].* ]] ; then
	echo "bad oid number, must start with 1."
	exit 2
else
	snmpwalk -v3 -l authPriv -u zabbix -a SHA -A nine10Eleven -x DES -X nine10Eleven $ip.$switch:161 $oid
fi
