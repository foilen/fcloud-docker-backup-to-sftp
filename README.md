FCloud Docker Backup to SFTP
==============

To be able to backup home directories to an SFTP account.

Build
-----

./create-local-release.sh

Usage
-----

Environment variables to set:
- HOST_NAME: The hostname of the machine. Used in the path where the backup is saved.
- SSH_HOSTNAME: The hostname of the ssh.
- SSH_PORT: The port of the ssh (default 22).
- SSH_USER: The username to use for ssh.
- SSH_KEYFILE: The path to the file with the ssh identity file (default /id_rsa).
- REMOTE_PATH: The path where to store the files on the remote server

Volume to mount:
- /backupRoot: The directory with sub-directories to save in separate tar.gz files.

The tar files will be saved in sftp://$REMOTE_PATH/$HOST_NAME/$NOW/$DIR.tar.gz

Usage Example
-----

```
# Compile
./create-local-release.sh

# Create fake home directories
HOST_HOME_DIR=$(mktemp -d)
mkdir $HOST_HOME_DIR/user1
mkdir $HOST_HOME_DIR/user2
echo Testing > $HOST_HOME_DIR/user1/f1.txt
echo Testing > $HOST_HOME_DIR/user1/f2.txt
echo Testing > $HOST_HOME_DIR/user2/f3.txt

# Create the key
HOST_SSH_KEYFILE=$(mktemp)
cat > $HOST_SSH_KEYFILE << _EOF
-----BEGIN RSA PRIVATE KEY-----
[...]
-----END RSA PRIVATE KEY-----
_EOF

# Execute 
docker run -ti --rm \
  --env HOST_NAME=$(hostname -f) \
  --env SSH_HOSTNAME=backup.example.com \
  --env SSH_PORT=22 \
  --env SSH_USER=fcloud-backup \
  --env SSH_KEYFILE=/id_rsa \
  --env REMOTE_PATH=/home/fcloud-backup/backup \
	--volume $HOST_SSH_KEYFILE:/id_rsa \
	--volume $HOST_HOME_DIR:/backupRoot \
	fcloud-docker-backup-to-sftp:master-SNAPSHOT

```

Steps
-----

The archiving is done in multiple steps:
- The directory `sftp://$REMOTE_PATH/$HOST_NAME/$NOW/` is created
- For each directory to backup:
	- Creates the file `sftp://$REMOTE_PATH/$HOST_NAME/$NOW/$DIR.tar.gz.tmp` while filling it
	- Once fully saved, moves the file to `sftp://$REMOTE_PATH/$HOST_NAME/$NOW/$DIR.tar.gz`
- When completed, creates `sftp://$REMOTE_PATH/$HOST_NAME/$NOW/BACKUP_COMPLETED.txt` to let us know the process didn't stop in the middle
