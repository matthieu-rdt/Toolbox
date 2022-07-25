#	Creation of a temp file
filename=`mktemp /tmp/list_of_variables_XXX_$$`
cat << EOF > $filename
#	A list of variables
variable1=""
variable2=""
variable3=""
EOF

if [ $(grep -E '""$' $filename | echo $?) -eq 0 ] ; then
        echo "The variables list are empty"
fi
