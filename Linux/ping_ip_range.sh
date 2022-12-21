#!/bin/bash
read -p 'which ip range do wanna test ? (first 3 bytes) ' ip
read -p 'up to which byte do you want to go ? ' last

for (( c=1; c<=$last; c++ ))
do
	ping -c 1 $ip.$c > /dev/null
	if [ $(echo $?) -eq 1 ] ; then 
		echo "$ip.$c - non ok"
	else
		echo "$ip.$c"
	fi
done
