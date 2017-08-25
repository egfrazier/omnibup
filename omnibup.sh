#!/bin/bash
#
#*******************************************************************#
# Name: OmniBup                                                     #
# Author: Elizabeth Frazier                                         #
# Creation Date: 2017-06-26                                         #
# Version: 0.0.1                                                    #
# Description: A script to automatically backup files from          #
# a remote host to this local host. Meant to be run as a cron job.   #
#*******************************************************************#

# CONFIG SETTINGS

# Main config settings
LOCAL_BACKUP_DIR="/rsync_backups/ddv"
LOCAL_USER="efrazier"
LOCAL_SSH_KEY_ID_FILE="/home/liz/.ssh/mt/docker-extras/id_rsa"

REMOTE_USER="efrazier"
REMOTE_HOST="70.32.73.208"
REMOTE_LOCATION="/"
REMOTE_RSYNC_PATH="sudo /usr/bin/rsync" # Sudo is required before the path in order for the SSHed user to perform rsync as root on the remote host
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# Email Notification Config Settings
NOTIFICATION_EMAIL=""
RELAY_EMAIL=""

# Rotation Config settings


# BACKUP TO LOCAL ENVIRONMENT
#
# You will need to set up a cron/scheduled task
# on your local machine that will invoke this
# backup script(using the configuration parameters
# above), the close.

# First, ensure backup directory exists on the local host
if [ ! -d $LOCAL_BACKUP_DIR ]
then
    echo "Backup directory ($LOCAL_BACKUP_DIR) does not exist"
    echo "Creating directory at $LOCAL_BACKUP_DIR..."
    sudo mkdir $LOCAL_BACKUP_DIR
    sudo touch $LOCAL_BACKUP_DIR/timestamp
else
    echo "Confirmed backup directory at $LOCAL_BACKUP_DIR exists."
fi

# Run the rsync command
sudo rsync -Pav --rsync-path="$REMOTE_RSYNC_PATH" -e "ssh -i $LOCAL_SSH_KEY_ID_FILE" $REMOTE_USER@$REMOTE_HOST:$REMOTE_LOCATION --exclude={"/proc/","/sys/"} $LOCAL_BACKUP_DIR > $LOCAL_BACKUP_DIR/xfer_log

# Update backup timestamp
date +%Y-%m-%d_%H-%M-%S > $LOCAL_BACKUP_DIR/timestamp
echo "Timestamp updated. New backup timestamp is $(cat $LOCAL_BACKUP_DIR/timestamp)"
echo "Backup completed"
