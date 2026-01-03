#!/bin/bash
config="mnt.conf"
log_file="$HOME/amsh.log"

log_event() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$log_file"
}
check_log(){
    if [ ! -f "$log_file" ]; then
        touch "$log_file"
    fi
    if [ ! -w "$log_file" ]; then
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

cronos(){
    local dir="$1"
    local timp_curent=$(echo "$dir" | tr '/' '_')
    touch "/tmp/last_access${timp_curent}"
    log_event "TIMESTAMP ACTUALIZAT: $dir"
}

echo "Automounter Shell pornit."
log_event "Shell-ul a fost pornit de $USER."

while true; do
    printf "> "
    read -r linie
    
    [ -z "$linie" ] && continue
    [ "$linie" == "exit" ] && break

    comanda=$(echo "$linie" | awk '{print $1}')
    argumente=$(echo "$linie" | cut -d' ' -f2-)

    if [ "$comanda" == "cd" ]; then
        if [ "$argumente" == "cd" ] || [ -z "$argumente" ]; then
            tinta=$HOME
        else
            tinta=$argumente
        fi

        if check_config "$tinta"; then
            echo "Director special detectat. Se marcheaza accesul."
            cronos "$tinta"
        fi

        builtin cd "$tinta" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "Eroare: Directorul '$tinta' nu exista."
        fi
    else
        $linie
    fi
done
