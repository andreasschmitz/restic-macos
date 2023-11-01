#!/bin/bash
# Makes sure that no one overwrites commands
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


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
BACKUP_ALLOWED_WIFI_NAMES RESTIC_REPOSITORY RESTIC_PASSWORD_COMMAND


if [ ! -f $RESTIC_REPOSITORY_FILE ]; then
	echo "File $RESTIC_REPOSITORY_FILE does not exist."
	exit 3
fi

eval "$RESTIC_PASSWORD_COMMAND" > /dev/null 2>&1
if [ ! $? -eq 0  ]; then
	echo "Restic backup cannot be found in Keychain. Please enter the password below."
	security add-generic-password -s backup-restic-password-repository -a restic_backup -w
fi


# Checks which interface is currently used as default route. Exits if there isn't one.
DEFAULT_INTERFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
if [[ $DEFAULT_INTERFACE == "" ]]; then
	echo $(date +"%Y-%m-%d %T") "No network connection (default route) available. Exiting…"
	exit 6
fi

# Check if the default route is a wifi. If so and the network name is not on the allow list, we exit.
networksetup -getairportnetwork $DEFAULT_INTERFACE 1>/dev/null 2>&1
if [[ $? -eq 0 && ! $(networksetup -getairportnetwork $DEFAULT_INTERFACE | grep -E "$BACKUP_ALLOWED_WIFI_NAMES") ]]; then
	echo $(date +"%Y-%m-%d %T") "The current Wi-Fi network is not on the allow list. Exiting…"
	exit 7
fi

if [[ $BACKUP_ALLOW_ON_BATTERY == "0" && $(pmset -g ps | head -1) =~ "Battery" ]]; then
  echo $(date +"%Y-%m-%d %T") "Computer is running on battery power. Exiting…"
  exit 8
fi


# Perform Post Backup check
echo $(date +"%Y-%m-%d %T") "Checking backup…"
/opt/homebrew/bin/restic check --verbose

if [[ $? -eq 0 ]]; then
  # 0 when the backup was successful (snapshot with all source files created)
  anybar green
elif [[ $? -eq 3 ]]; then
  # 3 when some source files could not be read (incomplete snapshot with remaining files created)
  anybar orange
else
  # 1 when there was a fatal error (no snapshot created)
  anybar red
fi


echo $(date +"%Y-%m-%d %T") "Check finished"

exit 0