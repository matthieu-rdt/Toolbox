#! /bin/bash

pkg=xclip

status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
	sudo apt install xclip
fi

xclip -selection clipboard -i $@
