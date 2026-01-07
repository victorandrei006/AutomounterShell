#!/bin/bash
config="mnt.conf"
log_file="$HOME/.amsh/amsh.log"

# Scrie mesaje in fisierul de log cu data si ora curenta
log_event() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$log_file"
}

on_exit() {
    log_event "Shell-ul se inchide."
    exit 0
}

check_log(){
log_dir=$(dirname "$log_file")
if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"        # Creez folderul ascuns daca nu exista
fi
[ ! -f "$log_file" ] && touch "$log_file"    
if [ ! -w "$log_file" ]; then
        echo "Eroare: lipsa permisiune de scriere!"
        exit 
    fi
}

# Verifica daca un director este prezent in mnt.conf
check_config() {
    local target_dir="$1"
    [ ! -f "$config" ] && return 1
    grep -q "^$target_dir " "$config"
}

cronos(){
    local dir="$1"
    # Inlocuim '/' cu '_' pentru ca numele fisierului sa fie valid
    local nume_fisier=$(echo "$dir" | tr '/' '_')
    touch "/tmp/last_access${nume_fisier}"
    log_event "Timestamp actualizat: $dir"
}

check_log
trap on_exit EXIT SIGINT SIGTERM

echo "Automounter Shell pornit."
log_event "Shell-ul a fost pornit de $USER."

while true; do
    printf "amsh [%s] > " "$(pwd)"
    read -r linie
    
    [ -z "$linie" ] && continue
    [[ "$linie" =~ ^(exit|q|done)$ ]] && break

    comanda=$(echo "$linie" | awk '{print $1}')
    argumente=$(echo "$linie" | cut -d' ' -f2-)
    # recunoastem comanda cd drept comanda pentru automount
    if [ "$comanda" == "cd" ]; then
        if [ -z "$argumente" ]; then target=$HOME; else target=$argumente; fi
        
        if builtin cd "$target" 2>/dev/null; then
            target_abs=$(pwd)
            
            if check_config "$target_abs"; then
                # Extragem dispozitivul (coloana 2 din mnt.conf)
                dispozitiv=$(grep "^$target_abs " "$config" | awk '{print $2}')

                if ! mountpoint -q "$target_abs"; then
                    echo "Detectat mountpoint in config. Se monteaza..."
                    # Adaugam -o loop pentru test cu imagine virtuala
                    sudo mount -o loop "$dispozitiv" "$target_abs"
                    
                    if [ $? -eq 0 ]; then
                        echo "Succes! Dispozitivul a fost montat."
                        log_event "Montare reusita: $dispozitiv pe $target_abs"
                    else
                        echo "Eroare la montare!"
                    fi
                fi
                cronos "$target_abs"
            fi
        else
            echo "Eroare: Directorul '$target' nu exista."
        fi
    else
        eval "$linie"
    fi
done