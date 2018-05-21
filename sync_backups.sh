#!/bin/bash
BACKUP_USER=${BACKUP_USER:-admin}
BACKUP_SERVER=${BACKUP_SERVER:-nas.int}
BACKUP_DEST=${BACKUP_DEST:-/volume1/backup}
BACKUP_PATH=${BACKUP_PATH:-:/var/backup}

HOMEDIR=$(getent passwd $USER | cut -d: -f6)
DIRS="$HOMEDIR"

STATUS=`dig +short ${BACKUP_SERVER}`
if [ -z "${STATUS}" ]; then
    echo "backup server ${BACKUP_SERVER} not available; skipping"
    exit 2
fi

sudo echo "starting sync -> ${BACKUP_SERVER}..."

sudo rsync -avz --progress --delete ${BACKUP_PATH}/ admin@${BACKUP_SERVER}:${BACKUP_DEST}/
