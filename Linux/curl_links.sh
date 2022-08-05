#!/bin/bash

# indicate a filename as argument to the script (note : double quotes for $1 in case of space in the filename)
file="$1"

# count number of lines without filter
ppg=$(wc -w "$file" | cut -d ' ' -f 1)

# compare if the number of lines using a url format is the same than the whole file (mib, sh extensions)
# you can add more with pipe separated : (mib|php|sh|txt) for instance
vg=$(grep -E '^https?://.*.(mib|sh)' "$file" | wc -w)

check_if_packages_installed () 
{
if [[ $(dpkg-query -W -f='${Status}' dos2unix 2>/dev/null | grep -c "ok installed") -eq 0 ]] ; then 
	sudo apt install dos2unix
fi
# avoid reading file issue
dos2unix "$file"
}

check_each_line_is_a_link ()
{
if [[ $ppg -eq $vg ]] ; then 
	echo "all the lines are links"
else
	echo "all the lines aren't links"
	exit 11
fi
}

download_links ()
{
if [[ -f "$file" ]] ; then
	while IFS= read -r line
	do
	curl -O "$line"
	done < "$file"
elif [[ $1 =~ ^https?://.*.(mib|sh) ]] ; then
	curl -O "$1"
else
	echo "$1 is neither a file nor a link"
	exit 22
fi
}

if [[ -z $1 ]] ; then
	echo "filename or URL required"
	exit 33
fi

check_if_packages_installed

check_each_line_is_a_link 

download_links "$file"
