#!/bin/bash

MONITOR_FILE="$1"
LOG_FILE="$2"
TIMEOUT=300

[ -z "$MONITOR_FILE" ] && MONITOR_FILE="/tmp/amsh_monitor"
[ -z "$LOG_FILE" ] && LOG_FILE="$HOME/amsh.log"

log_c() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [Cerberus] $1" >> "$LOG_FILE"
}

log_c "Daemon pornit. Monitorizez: $MONITOR_FILE"

while true; do
    if [ -f "$MONITOR_FILE" ]; then
        
        now=$(date +%s)
        file_time=$(stat -c %Y "$MONITOR_FILE")
        age=$((now - file_time))

        if [ $age -ge $TIMEOUT ]; then
            
            folder_de_demontat=$(cat "$MONITOR_FILE")
            
            if [ -n "$folder_de_demontat" ] && mountpoint -q "$folder_de_demontat"; then
                
                sudo umount -l "$folder_de_demontat"
                
                if [ $? -eq 0 ]; then
                    log_c "Am demontat automat: $folder_de_demontat"
                    rm -f "$MONITOR_FILE"
                else
                    log_c "Eroare demontare pentru: $folder_de_demontat"
                fi
            else
                rm -f "$MONITOR_FILE"
            fi
        fi
    fi
    
    sleep 2
done