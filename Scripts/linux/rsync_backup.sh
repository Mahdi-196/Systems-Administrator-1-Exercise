#!/bin/bash
# Incremental backup using rsync

SOURCE="${1:-/home/sysadmin/important_files/}"
DEST="${2:-/home/sysadmin/backup_destination/}"
LOG="/home/sysadmin/rsync_backup.log"

echo "[$(date)] Starting backup: $SOURCE -> $DEST" | tee -a "$LOG"

rsync -avh --progress "$SOURCE" "$DEST" 2>&1 | tee -a "$LOG"

echo "[$(date)] Backup complete" | tee -a "$LOG"
