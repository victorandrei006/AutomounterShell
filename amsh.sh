#!/bin/bash

log_event() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> ~/amsh.log
}


echo "Automounter Shell pornit."
log_event "Shell-ul a fost pornit de $USER."

while true; do
    printf ">"
    read -r comanda
    [ "$comanda" == "exit" ] && break
    $comanda
done