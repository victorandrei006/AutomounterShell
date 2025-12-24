#!/bin/bash
config="mnt.conf"

log_event() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> ~/amsh.log
}

check_config() {
    local target_dir="$1"

    if [ ! -f "$config" ]; then
        return 1
    fi

    if grep -q "^target_dir" "$config"; then
        return 0
    else
       return 1
    fi
}

echo "Automounter Shell pornit."
log_event "Shell-ul a fost pornit de $USER."

while true; do
    printf ">"
    read -r comanda
    [ "$comanda" == "exit" ] && break
    $comanda
done
