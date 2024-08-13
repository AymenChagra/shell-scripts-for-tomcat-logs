#!/bin/bash

# Chemin vers le fichier de log Tomcat
log_file="/home/aymen/server_logs/access_log"

# Fichier temporaire pour stocker les logs du jour
last_logs="/home/aymen/last_logs.log"

# Initialiser le pic d'occurance à 0
peakocc=0

# Initialiser l'heure du pic à une valeur vide
peakh=""

# La date actuelle au format DD/MMM/YYYY pour correspondre au format du fichier log
current_date=$(date +"%d/%b/%Y")
# Extraire les lignes du log correspondant à la date actuelle
yesterday_date=$(date -d 'yesterday' +"%d/%b/%Y")
grep -E "$current_date|$yesterday_date" "$log_file" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' > "$last_logs"


# Calculer le seuil de temps il y a 24 heures
time_threshold=$(date -d '24 hours ago' +"%d/%b/%Y:%H:%M:%S")

# Suppression des logs qui ont dépassé les 24 heures
awk -v threshold="$time_threshold" '
{
    # Extraire la date et lheure du log (format [DD/MMM/YYYY:HH:MM:SS])
    log_date_time = substr($4, 2) " " substr($5, 1, length($5) - 1) # Enlever les crochets et espaces
    if (log_date_time > threshold) {
        print $0
    }
}' "$last_logs" > "${last_logs}_tmp" && mv "${last_logs}_tmp" "$last_logs"

# Parcourir chaque heure de 00 à 23
for hour in {00..23}; do
    # Compter les occurrences pour l'heure actuelle dans les logs extraits
    occ=$(grep -oP "\[\d{2}/[A-Za-z]{3}/\d{4}:$hour" "$last_logs" | wc -l)
    # Vérifier si le nombre de requêtes à l'heure actuelle dépasse le pic précédent
    if [ "$occ" -ge "$peakocc" ]; then
        peakocc=$occ
        peakh=$hour
    fi
done


#le nombre de requete effectué pendant les derniers 24 heures
nb_req=$(wc -l < "$last_logs")
echo "$nb_req requête(s) effectuée(s) pendant les dernières 24 heures [$time_threshold --> $(date +"%d/%b/%Y:%H:%M:%S")]"

#afficher l'heure du pic
echo "Le pic du traffic est atteint à $peakh h avec $peakocc requête(s)"

#le nombre de machines qui ont communiqué avec le serveur
nb_machines=$(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' $last_logs | awk '!seen[$0]++' | wc -l) 
echo "le nombre de machines qui ont communiqués avec le serveur est $nb_machines" 

#le client qui a communique le plus 
ip_machine=$(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' "$last_logs" | sort | uniq -c | sort -nr | head -n 1 | awk '{$1=""; print $0}')
echo "la machine qui a communiqué le plus est $ip_machine"

#afficher les logs des derniers 24h
echo "
voici les logs des derniers 24 heures :"
cat $last_logs
