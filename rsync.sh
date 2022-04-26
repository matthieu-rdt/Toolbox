#!/bin/bash

documentation () {
echo "Options disponibles (non exhaustives) :
    -dr = --dry-run : visualiser les fichiers 'source' a coper vers 'destination' (action a blanc)
    -ndr = --no-dry-run : effectuer la copie des fichiers 'source' vers 'destination'
    -d = --delete ...
"
}

if      [[ -z $1 ]] ; then
                echo "Essaye './backup.sh -h' pour plus d'informations"
                exit 1
else
        echo "Astuce 1 :
        Si tu veux copier ton dossier 'source' en tant que tel
        - utilise > /home/user/source (pas de slash final)

        Astuce 2 :
        Si tu veux copier le contenu du dossier 'source'
        - utilise > /home/user/source/ (avec un slash final)"

        read -p 'Indique la source a copier ' src

        sleep 1

        read -p 'Indique la destination a copier ' dst

        if      [[ $1 == -h ]] ; then
                documentation
                
        elif    [[ $1 == -dr ]] ; then
                rsync -avP --dry-run $src $dst

        elif    [[ $1 == -ndr ]] ; then
                rsync -avP $src $dst

        fi
fi