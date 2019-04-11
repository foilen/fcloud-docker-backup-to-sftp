#!/bin/bash

set -e

# Check the environment variables are present 
if [ -z "$HOST_NAME" ]; then
  echo HOST_NAME environment is not set
  exit 1
fi
if [ -z "$SSH_HOSTNAME" ]; then
  echo SSH_HOSTNAME environment is not set
  exit 1
fi
if [ -z "$SSH_PORT" ]; then
  export SSH_PORT=22
fi
if [ -z "$SSH_USER" ]; then
  echo SSH_USER environment is not set
  exit 1
fi
if [ -z "$SSH_HOSTNAME" ]; then
  echo SSH_HOSTNAME environment is not set
  exit 1
fi
if [ -z "$REMOTE_PATH" ]; then
  echo REMOTE_PATH environment is not set
  exit 1
fi

if [ -z "$SSH_KEYFILE" ]; then
  export SSH_KEYFILE=/id_rsa
fi
if [ ! -f $SSH_KEYFILE ]; then
  echo Key file $SSH_KEYFILE is missing
  exit 1
fi

BACKUP_ROOT=/backupRoot
PATH=$PATH:/usr/local/sbin
NOW=$(date +%Y-%m-%d-%H-%M-%S)

# Ensure key permissions
chmod 600 $SSH_KEYFILE

# Create remote backup directory 
ssh -oStrictHostKeyChecking=no -i "$SSH_KEYFILE" "$SSH_USER"@"$SSH_HOSTNAME" -p "$SSH_PORT" "mkdir -p $REMOTE_PATH/$HOST_NAME/$NOW/"

# Archive all
cd $BACKUP_ROOT
for DIR in $(ls)
do
  echo Saving to $REMOTE_PATH/$HOST_NAME/$NOW/$DIR.tar.gz.tmp
  tar -zc $DIR | ssh -oStrictHostKeyChecking=no -i "$SSH_KEYFILE" "$SSH_USER"@"$SSH_HOSTNAME" -p "$SSH_PORT" "cat > $REMOTE_PATH/$HOST_NAME/$NOW/$DIR.tar.gz.tmp"
  echo Renaming to $REMOTE_PATH/$HOST_NAME/$NOW/$DIR.tar.gz
  ssh -oStrictHostKeyChecking=no -i "$SSH_KEYFILE" "$SSH_USER"@"$SSH_HOSTNAME" -p "$SSH_PORT" "mv $REMOTE_PATH/$HOST_NAME/$NOW/$DIR.tar.gz.tmp $REMOTE_PATH/$HOST_NAME/$NOW/$DIR.tar.gz"
done

# Tell it is completed
ssh -oStrictHostKeyChecking=no -i "$SSH_KEYFILE" "$SSH_USER"@"$SSH_HOSTNAME" -p "$SSH_PORT" "touch $REMOTE_PATH/$HOST_NAME/$NOW/BACKUP_COMPLETED.txt"

echo Backup completed successfully
