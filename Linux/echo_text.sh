#!/bin/bash

declare -a text=(
"line 1"
"line 2"
"line 3"
)

for line in "${text[@]}"; do
        echo $line
done
