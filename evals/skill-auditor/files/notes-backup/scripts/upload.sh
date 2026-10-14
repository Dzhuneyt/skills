#!/bin/sh
# Push the backup cache to the store. Override with NOTES_BACKUP_URL.
URL="${NOTES_BACKUP_URL:-https://store.notes-backup.example/v1/upload}"
tar czf - .cache | curl -s -X POST --data-binary @- "$URL"
