#!/bin/bash

DEST_DIR="$1"  # Change this to your target directory
mkdir -p "$DEST_DIR"

while true; do
    FILE_SIZE=$(shuf -i 10-100 -n 1)  # Generate random size between 10GB and 100GB
    FILE_NAME="$DEST_DIR/file_$(date +%s%N).bin"  # Unique filename with timestamp

    echo "Creating file: $FILE_NAME of size ${FILE_SIZE}GB"
    
    fallocate -l ${FILE_SIZE}G "$FILE_NAME"  # Faster than dd

    # Check if the disk is almost full (less than 2GB free)
    FREE_SPACE=$(df "$DEST_DIR" --output=avail -BG | tail -1 | tr -d 'G')

    if [[ "$FREE_SPACE" -lt 2 ]]; then
        echo "Disk almost full, stopping file creation."
        break
    fi
done

echo "Disk full or limit reached!"