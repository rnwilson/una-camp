#!/bin/bash

has_error() {
    [ ! -f "$PWD/builder_error.log" ]; touch "$PWD/builder_error.log";
    while getopts "m:" opt; do
        case $opt in
            m) multi+=("$OPTARG");;
            *) echo "Error: -m";;
        esac
    done
    shift $((OPTIND -1))
    for val in "${multi[@]}"; do
        printf "***Error: %s\n" "$val" >> "$PWD/builder_error.log"
    done
    exit 1
}

DOTENV=".env.example"

if [ -f "$PWD/$DOTENV" ]; then
    if [ ! -f "$PWD/apache/apache-cont1/entrypoint-var.env" ]; then
        cp "$PWD/$DOTENV" "$PWD/entrypoint-var.env"
        mv "$PWD/entrypoint-var.env" "$PWD/apache/apache-cont1/"
        sed -i -e 's/^/export /' "$PWD/apache/apache-cont1/entrypoint-var.env"

        if [ ! -f "$PWD/.env" ]; then 
            cp "$PWD/$DOTENV" "$PWD/.env" 
            rm "$PWD/$DOTENV"
        else
            has_error -m "$PWD/.env exists"
        fi
    else
        has_error -m "$PWD/apache/apache-cont1/entrypoint-var.env exists"
    fi
fi

VOL="$PWD/vol"

if [ ! -d "$VOL" ]; then
    MDIRS=("$VOL" "$VOL/logs" "$VOL/mysql" "$VOL/certs")    
    WDIRS=("$VOL/html/cache/" "$VOL/html/inc/" "$VOL/html/tmp/" "$VOL/html/cache_public/" "$VOL/html/logs/" "$VOL/html/storage/")
    XDIRS="$VOL/html/plugins/ffmpeg/ffmpeg.exe"

    for i in "${MDIRS[@]}"; do
        mkdir -p "$i"

        if [ ! -d "$i" ]; then has_error -m "$i does not exist" else printf "Run: mkdir %s\n" "$i"; fi
    done
    
    git clone https://github.com/unaio/una.git "$VOL/html"
    
    if [ ! -d "$VOL/html" ]; then
        has_error -m "$VOL/html does not exist"
    else
        for i in "${WDIRS[@]}"; do
            if [ -d "$i" ]; then  
                if chmod +w "$i"; then 
                    printf "Ok: chmod +w %s\n" "$i" 
                else 
                    has_error "$i does not exist"
                fi
            else
                has_error -m "chmod +w $i"
            fi
        done
    fi

    if ! chmod +x "$VOL/html/plugins/ffmpeg/ffmpeg.exe"; then has_error -m "$XDIRS" else echo "Ok: $XDIRS"; fi
else
    has_error -m "$VOL already exists"
fi