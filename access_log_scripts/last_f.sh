#!/bin/bash

# Répertoire personnel
HOME_DIR="/home/aymen"

# Afficher les derniers fichiers créés (excluant les fichiers cachés) dans le répertoire personnel
find $HOME_DIR -maxdepth 1 -type f ! -name ".*" -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -5 | cut -f2- -d' '

