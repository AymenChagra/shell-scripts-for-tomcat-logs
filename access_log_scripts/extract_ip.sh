#!/bin/bash

# Chemin vers le fichier log
log_file="/home/aymen/server_logs/access_log"

# Chemin vers le dossier qui va contenir le nouveau fichier log TCP/IP 
output_dir="/home/aymen/ip_log"

# la date actuelle au format DD/MMM/YYYY pour correspondre au format du log
current_date=$(date +"%d/%b/%Y")

# Fichier de sortie basé sur la date actuelle
output_file="$output_dir/ips_$(date +"%d-%m-%Y").log"

# Extraire les adresses IP de la date d'aujourd'hui et les sauvegarder dans le fichier de sortie
grep "$current_date" "$log_file" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' > "$output_file"

# Afficher un message de confirmation et le contenu du fichier de log TCP/IP
echo "Les adresses IP ont été extraites et sauvegardées dans $output_file"
echo "Voici les TCP/IP pour la date d'aujourd'hui ($current_date):"
cat "$output_file"

# Supprimer les fichiers générés depuis plus de 5 jours
find "$output_dir" -name "ips_*.log" -mtime +5 -exec rm {} \;



#pour voir seulement les ips et sans redandonce 
#grep "$current_date" "$log_file" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '!seen[$0]++' > "$output_file"
