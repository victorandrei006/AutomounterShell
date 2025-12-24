#!/bin/bash
config="mnt.conf"
log_file="$HOME/amsh.log"

log_event() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$log_file"
}
check_log(){
    if [ ! -f "$log_file"]; then
    touch "$log_file"
    fi
    if [ ! -w "$log_file"]; then
    echo "ERROR: lipsa permisiune de scriere!"
    exit 1
    fi
}

check_config() {
    local target_dir="$1"

    if [ ! -f "$config" ]; then
        return 1
    fi

    if grep -q "^$target_dir" "$config"; then
        return 0
    else
       return 1
    fi
}

echo "Automounter Shell pornit."
log_event "Shell-ul a fost pornit de $USER."

while true; do
    printf ">"
    echo "1"
    read -r comanda
    [ "$comanda" == "exit" ] && break
    [ "$comanda" == "q" ] && break
    [ "$comanda" == "done" ] && break
    $comanda
done
