#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
config="$SCRIPT_DIR/mnt.conf"
log_file="$HOME/amsh.log"

log_event() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$log_file"
}

on_exit() {
    log_event "Shell-ul se inchide."
    exit 0
}

check_log(){
    if [ ! -f "$log_file" ]; then
        touch "$log_file"
    fi
    if [ ! -w "$log_file" ]; then
        echo "Eroare: lipsa permisiune de scriere!"
        exit 1
    fi
}

cronos(){
    local dir="$1"
    local timp_curent=$(echo "$dir" | tr '/' '_')
    touch "/tmp/last_access${timp_curent}"
    log_event "Timestamp actualizat: $dir"
}

echo "Automounter Shell pornit."
log_event "Shell-ul a fost pornit de $USER."

check_log

if [ -x "./cerberus.sh" ]; then
    ./cerberus.sh > /dev/null 2>&1 &

    CERBERUS_PID=$!
    
    log_event "Cerberus pornit in background cu PID: $CERBERUS_PID"
    echo "Cerberus vegheaza (PID: $CERBERUS_PID)..."
else
    echo "Eroare: cerberus.sh nu a fost gasit sau nu are permisiuni de executie!"
fi

trap on_exit EXIT SIGINT SIGTERM

while true; do
    printf "amsh [%s] > " "$(pwd)"
    read -r linie
    
    [ -z "$linie" ] && continue
    [ "$linie" == "exit" ] && break
    [ "$linie" == "q" ] && break

    comanda=$(echo "$linie" | awk '{print $1}')
    argumente=$(echo "$linie" | cut -d' ' -f2-)

    if [ "$comanda" == "cd" ]; then
        if [ -z "$argumente" ] || [ "$argumente" == "cd" ]; then
            target=$HOME
        else
            target=$argumente
        fi
        
        if [ -d "$target" ]; then
            target_abs=$(cd "$target" && pwd)
            
            dispozitiv=$(awk -v path="$target_abs" '$1 == path {print $2}' "$config")

            if [ -n "$dispozitiv" ]; then
                if ! mountpoint -q "$target_abs"; then
                    echo "Se montează $dispozitiv pe $target_abs..."
                    sleep 0.5
                    echo "Se montează $dispozitiv pe $target_abs..."
                    sleep 0.5
                    echo "Se montează $dispozitiv pe $target_abs..."
                    sudo mount "$dispozitiv" "$target_abs"
                    
                    if [ $? -eq 0 ]; then
                        log_event "Succes: $dispozitiv montat pe $target_abs"
                    else
                        log_event "Eroare: Nu s-a putut monta $dispozitiv"
                    fi
                fi
                cronos "$target_abs"
            fi

            builtin cd "$target_abs" 2>/dev/null
        else
            echo "Eroare: Directorul '$target' nu exista."
        fi
    else
        eval "$linie"
    fi
done