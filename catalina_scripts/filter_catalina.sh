#!/bin/bash

extract_ips() {
  # Chemin vers le fichier log
  local log_file=$1
  # Critère de filtrage pour grep
  local criteria=$2
  #faisseau horraire 
  local start=$3
  local end=$4
  
  # Chemin vers le dossier qui va contenir le nouveau fichier log TCP/IP 
  local output_dir="/home/aymen/server_analyses"
  
  # La date actuelle au format DD/MMM/YYYY pour correspondre au format du log
  local current_date=$(date +"%d/%b/%Y")
  
  # Fichier de sortie basé sur la date actuelle
  local output_file="$output_dir/output.log"
  
  # Vérification de l'existence du fichier log
  if [ ! -f "$log_file" ]; then
    echo "Erreur: Le fichier log $log_file n'existe pas."
    return 1
  fi

  # Extraction des adresses IP, heure et nom de compte selon le critère  
  grep -E "$criteria" "$log_file" | awk '{split($1,a,":"); split($0,b,"|"); print a[1]":"a[2] " " b[6] " " b[4]}' | grep -v '0.0.0.0' | 
  grep -E '^[0-9]{2}:[0-9]{2} [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ [A-Z]+' | grep -v '^-:' | sort | 
  awk -v start="$start" -v end="$end" '$1 >= start && $1 <= end' | awk '!seen[$0]++' > "$output_file"
  
  
  # Afficher un message de confirmation et le contenu du fichier de log TCP/IP
  echo "Les informations ont été extraites et sauvegardées dans $output_file"
  echo "Voici le contenu extrait :"
  cat "$output_file"
}

# Appel de la fonction avec le chemin du fichier log et le critère comme arguments
extract_ips "$1" "$2" "$3" "$4"


