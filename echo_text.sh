declare -a echo_text=(
"line 1"
"line 2"
"line 3"
)

for i in "${echo_test[@]}"
do
	echo $i
done
