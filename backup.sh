#!/bin/bash
BACKUP_PATH=${BACKUP_PATH:-/var/backup}

HOMEDIR=$(getent passwd $USER | cut -d: -f6)
DIRS="$HOMEDIR"

if [ -z "$(which zbackup)" ]; then
    echo "zbackup not installed"
    exit 1
fi

BACKUP_DEST=${BACKUP_PATH}/${USER}
mkdir -p ${BACKUP_DEST}

# TODO: check for available disk space

echo "starting backup: ${HOMEDIR} -> ${BACKUP_DEST}..."

date=`date "+%Y-%m-%dT%H:%M:%S"`
time sudo tar -vc \
    --exclude .cache \
    --exclude .dbus \
    --exclude *.swp \
    --exclude .config/google-chrome \
    --exclude .nvm \
    --exclude Steam \
    --exclude Android \
    --exclude media \
    --exclude vm \
    $HOMEDIR | sudo zbackup --non-encrypted backup $BACKUP_DEST/backups/backup-$date
sudo rm -f $BACKUP_DEST/backups/current
sudo ln -sf $BACKUP_DEST/backups/backup-$date $BACKUP_DEST/backups/current
