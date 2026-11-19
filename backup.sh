#!/usr/bin/env bash

CREDENTIALS_FILE="${HOME}/.config/restic/env"
INCLUDES_FILE="${HOME}/.config/restic/includes.txt"
EXCLUDES_FILE="${HOME}/.config/restic/excludes.txt"

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

#Importation des variables d'envirronement
if [[ -f "${CREDENTIALS_FILE}" ]]; then
	source "${CREDENTIALS_FILE}"
	echo "credentials trouvé"
else
	echo "Missing credentials in ${CREDENTIALS_FILE}."
	exit 1
fi

#Ajout d'un d'élai pour assurer une connexion internet
if [[ -z $@ ]]; then
	sleep 2m
fi

#Vérification d'une connexion internet
if ! ping -c 1 -t 5 1.1.1.1 >/dev/null 2>&1; then
    echo "$(date): Pas de connexion Internet, sauvegarde reportée." >&2
    exit 0
fi

echo "internet connecté"

#Lancement de la backup
caffeinate -sm restic -r "${URL}" backup  \
       --files-from "${INCLUDES_FILE}" \
       --exclude-file "${EXCLUDES_FILE}" \
       --exclude-larger-than 10G \
       --verbose

#Purge des anciennes backup
#/!\ à laisser APRES la backup.
caffeinate -sm restic -r "${URL}" forget \
	--keep-daily 7 \
	--keep-weekly 4 \
	--keep-monthly 12 \
	--prune \
	--verbose

