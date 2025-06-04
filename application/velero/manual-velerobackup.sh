#!/bin/bash

# Backup name with timestamp
BACKUP_NAME="manual-backup-all-namespaces-$(date +%Y%m%d%H%M%S)"

# Run the backup for all namespaces
echo "Creating backup: $BACKUP_NAME for all namespaces"
velero backup create $BACKUP_NAME --include-namespaces '*'

# Confirm creation
echo "Run 'velero backup describe $BACKUP_NAME' or 'velero backup logs $BACKUP_NAME' to check progress."
# Check if the backup was created successfully
if velero backup describe $BACKUP_NAME > /dev/null 2>&1; then
    echo "Backup $BACKUP_NAME created successfully."
else
    echo "Failed to create backup $BACKUP_NAME."
    exit 1
fi

# Confirm creation
echo "Run 'velero backup describe $BACKUP_NAME' or 'velero backup logs $BACKUP_NAME' to check progress."
# Check if the backup was created successfully
if velero backup describe $BACKUP_NAME > /dev/null 2>&1; then
    echo "Backup $BACKUP_NAME created successfully."
else
    echo "Failed to create backup $BACKUP_NAME."
    exit 1
fi
# Optionally, you can add a command to delete old backups if needed