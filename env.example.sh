# Backup script
# --------------------------------------------------------------------------------------------------------------------
export BACKUP_CONF_DIR=/Users/username/.config/restic
export BACKUP_ALLOWED_WIFI_NAMES="My Wifi Network Name|My Other Wifi Network Name"
export BACKUP_ALLOW_ON_BATTERY=1

# Retention policy - How many backups to keep.
# See https://restic.readthedocs.io/en/stable/060_forget.html?highlight=month#removing-snapshots-according-to-a-policy
export RESTIC_RETENTION_HOURS=10
export RESTIC_RETENTION_DAYS=14
export RESTIC_RETENTION_WEEKS=16
export RESTIC_RETENTION_MONTHS=18
export RESTIC_RETENTION_YEARS=3

# Restic native flags
# --------------------------------------------------------------------------------------------------------------------
export RESTIC_REPOSITORY=""
export RESTIC_PASSWORD_COMMAND='security find-generic-password -s backup-restic-password-repository -w'

# A tag to identify backup snapshots.
export RESTIC_BACKUP_TAG=launchd

