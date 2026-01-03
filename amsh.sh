#!/bin/bash
config="mnt.conf"
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

cronos(){
    local dir="$1"
    local timp_curent=$(echo "$dir" | tr '/' '_')
    touch "/tmp/last_access${timp_curent}"
    log_event "Timestamp actualizat: $dir"
}

echo "Automounter Shell pornit."
log_event "Shell-ul a fost pornit de $USER."

while true; do
    printf ">"
    read -r linie
    
    [ -z "$linie" ] && continue
    [ "$linie" == "exit" ] && break

    comanda=$(echo "$linie" | awk '{print $1}')
    argumente=$(echo "$linie" | cut -d' ' -f2-)

    if [ "$comanda" == "cd" ]; then
        if [ "$argumente" == "cd" ] || [ -z "$argumente" ]; then
            target=$HOME
        else
            target=$argumente
        fi

        if check_config "$target"; then
            dispozitiv=$(grep -w "^$target" "$config" | awk '{print $2}')

            if ! mountpoint -q "$target"; then
                echo "Se montează $dispozitiv pe $target"
                sudo mount "$dispozitiv" "$target"
                if [ $? -eq 0 ]; then
                    log_event "$dispozitiv a fost montat pe $target"
                else
                    log_event "Eroare: $dispozitiv nu a putut fi montat pe $target"
                fi
            fi
            cronos "$target"
        fi
  
    #odata ce scrii "cd" o sa dea mount la ce e in fisierul mnt.conf

        builtin cd "$target" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "Eroare: Directorul '$target' nu exista."
        fi
    else
        $linie
    fi
done
