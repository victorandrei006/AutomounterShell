#!/bin/bash
TIMEOUT=10

while true; do
    for f in /tmp/last_access*; do
        [ -e "$f" ] || continue
        
        now=$(date +%s)
        file_time=$(stat -c %Y "$f")
        age=$((now - file_time))

        if [ $age -ge $TIMEOUT ]; then
            temp_name="${f#/tmp/last_access}"
            folder_reconstituit=$(echo "$temp_name" | tr '_' '/')

            sudo umount "$folder_reconstituit"
            rm "$f"
        fi
    done
    sleep 5
done