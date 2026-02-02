#!/bin/bash
# Sync files to Google Drive using rclone

SOURCE="${1:-/home/sysadmin/important_files/}"
DEST="${2:-gdrive:Backups/ubuntu_server/}"
LOG="/home/sysadmin/gdrive_sync.log"

if ! command -v rclone &>/dev/null; then
    echo "Error: rclone not installed"
    exit 1
fi

echo "[$(date)] Syncing to Google Drive" | tee -a "$LOG"

rclone sync "$SOURCE" "$DEST" -v 2>&1 | tee -a "$LOG"

echo "[$(date)] Sync complete" | tee -a "$LOG"
