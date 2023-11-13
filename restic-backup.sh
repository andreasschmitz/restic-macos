#!/bin/bash

# Makes sure that no one overwrites commands
export PATH=/opt/homebrew/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


# Configuration
PID_FILE=$BACKUP_CONF_DIR/run.pid
EXCLUDE_FILE=$BACKUP_CONF_DIR/exclude.txt
INCLUDE_FILE=$BACKUP_CONF_DIR/backup.txt
GLOBAL_FLAGS="--verbose"


# To detect changes in the log files, we print out the current time stamp…
echo $(date +"%Y-%m-%d %T") "----"
echo $(date +"%Y-%m-%d %T") "----" >&2

# Assert that all needed environment variables are set.
assert_envvars() {
  local varnames=("$@")
  for varname in "${varnames[@]}"; do
    if [ -z ${!varname+x} ]; then
      printf "%s must be set for this script to work.\nDid you forget to source a $BACKUP_CONF_DIR/env.sh profile in the current shell before executing this script?\n" "$varname" >&2
      exit 1
    fi
  done
}

function anybar { 
  echo -n $1 | nc -4u -w0 localhost ${2:-1738}; 
}

assert_envvars \
RESTIC_REPOSITORY RESTIC_PASSWORD BACKUP_RETENTION_HOURS BACKUP_RETENTION_DAYS BACKUP_RETENTION_WEEKS BACKUP_RETENTION_MONTHS BACKUP_RETENTION_YEARS


# Configuration check
if [ ! -f $INCLUDE_FILE ]; then
    echo "File $INCLUDE_FILE does not exist."
    exit 2
fi

if [ ! -f $RESTIC_REPOSITORY_FILE ]; then
    echo "File $RESTIC_REPOSITORY_FILE does not exist."
    exit 3
fi



# Execution check
if [ -f "$PID_FILE" ]; then
  if ps -p $(cat $PID_FILE) > /dev/null; then
    echo $(date +"%Y-%m-%d %T") "File $PID_FILE exists. Backup is probably already in progress. Exiting…"
    exit 4
  else
    echo $(date +"%Y-%m-%d %T") "File $PID_FILE exists, but process" $(cat $PID_FILE) "not found. Removing PID file."
    rm $PID_FILE
  fi
fi


# Checks which interface is currently used as default route. Exits if there isn't one.
DEFAULT_INTERFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
if [[ $DEFAULT_INTERFACE == "" ]]; then
    echo $(date +"%Y-%m-%d %T") "No network connection (default route) available. Exiting…"
    exit 6
fi


if [[ "$BACKUP_ALLOWED_WIFI_NAMES" ]]; then
  # Check if the default route is a wifi. If so and the network name is not on the allow list, we exit.
  networksetup -getairportnetwork $DEFAULT_INTERFACE 1>/dev/null 2>&1
  if [[ $? -eq 0 && ! $(networksetup -getairportnetwork $DEFAULT_INTERFACE | grep -E "$BACKUP_ALLOWED_WIFI_NAMES") ]]; then
      echo $(date +"%Y-%m-%d %T") "The current Wi-Fi network is not on the allow list. Exiting…"
      exit 7
  fi
fi


if [[ $BACKUP_ALLOW_ON_BATTERY == "0" && $(pmset -g ps | head -1) =~ "Battery" ]]; then
  echo $(date +"%Y-%m-%d %T") "Computer is running on battery power. Exiting…"
  exit 8
fi

# Remove stale locks
restic unlock

echo $$ > $PID_FILE
echo $(date +"%Y-%m-%d %T") "Starting backup…"
# TODO: Increase stdout verbosity. Currently nothing is listed in the log file apart from start and end.
restic backup $GLOBAL_FLAGS \
  --no-scan \
  --files-from $INCLUDE_FILE \
  --exclude-file $EXCLUDE_FILE

RESTIC_STATUS=$?
echo "Restic finished with status $RESTIC_STATUS"
if [[ $RESTIC_STATUS -eq 0 ]]; then
  # 0 when the backup was successful (snapshot with all source files created)
  anybar green
elif [[ $RESTIC_STATUS -eq 3 ]]; then
  # 3 when some source files could not be read (incomplete snapshot with remaining files created)
  anybar orange
else
  # 1 when there was a fatal error (no snapshot created)
  anybar red
fi


# Clean up old snapshots
echo $(date +"%Y-%m-%d %T") "Remove old backups…"
restic forget $GLOBAL_FLAGS \
  --prune \
  --keep-hourly "$BACKUP_RETENTION_HOURS" \
  --keep-daily "$BACKUP_RETENTION_DAYS" \
  --keep-weekly "$BACKUP_RETENTION_WEEKS" \
  --keep-monthly "$BACKUP_RETENTION_MONTHS" \
  --keep-yearly "$BACKUP_RETENTION_YEARS"


echo $(date +"%Y-%m-%d %T") "Backup finished"
rm $PID_FILE

exit 0
