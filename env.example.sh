# Backup script
# --------------------------------------------------------------------------------------------------------------------
export BACKUP_CONF_DIR=/opt/restic/config/
export BACKUP_ALLOWED_WIFI_NAMES="My Wifi Network Name|My Other Wifi Network Name"
export BACKUP_ALLOW_ON_BATTERY=1

# Retention policy - How many backups to keep.
# See https://restic.readthedocs.io/en/stable/060_forget.html?highlight=month#removing-snapshots-according-to-a-policy
export BACKUP_RETENTION_HOURS=10
export BACKUP_RETENTION_DAYS=14
export BACKUP_RETENTION_WEEKS=16
export BACKUP_RETENTION_MONTHS=18
export BACKUP_RETENTION_YEARS=3

# Restic native flags
# --------------------------------------------------------------------------------------------------------------------
export RESTIC_REPOSITORY=""
export RESTIC_CACHE_DIR=/Library/Caches/restic/

# A tag to identify backup snapshots.
export RESTIC_BACKUP_TAG=launchd
