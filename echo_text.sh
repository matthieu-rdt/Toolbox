echo_text=(
"line 1"
"line 2"
"line 3"
)

array_length=${#echo_text[@]}
for (( i=0; i<=array_length; i++ ))
do
echo "${echo_test[$i]} | sudo tee -a /file/path
done
}