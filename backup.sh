#!/bin/bash
BACKUP_PATH=${BACKUP_PATH:-/mnt/1tb/backup}

HOMEDIR=$(getent passwd $USER | cut -d: -f6)
DIRS="$HOMEDIR"

if [ -z "$(which zbackup)" ]; then
    echo "zbackup not installed"
    exit 1
fi

STATUS=`mount | grep 1tb`
if [ $? -eq 0 ]; then
    date=`date "+%Y-%m-%dT%H:%M:%S"`
    time sudo tar c \
        --exclude .cache \
        --exclude .dbus \
        --exclude *.swp \
        --exclude .config/google-chrome \
        --exclude .nvm \
        $HOMEDIR | zbackup --non-encrypted backup $BACKUP_PATH/backups/backup-$date
    rm -f $BACKUP_PATH/backups/current
    ln -sf $BACKUP_PATH/backups/backup-$date $BACKUP_PATH/current
else
    echo "backup drive not mounted; skipping"
fi
