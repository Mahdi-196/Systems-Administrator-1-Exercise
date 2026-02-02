# Systems Administrator 1 Exercise

A dual-platform infrastructure deployment exercise covering Ubuntu Server and Windows Server 2022 with Active Directory.

## Documentation

[Full SOP Guide](Documentation/System_Admin_Exercise_SOP.md)

---

## Scripts

### Linux (`Scripts/linux/`)

| Script | Description |
|--------|-------------|
| `create_users.sh` | Creates 5 organizational users with temporary passwords |
| `create_groups.sh` | Creates Teachers, Students, Staff, and All_Staff groups |
| `user_activity.sh` | Generates a report of login history and failed auth attempts |
| `rsync_backup.sh` | Performs incremental backup using rsync with logging |
| `gdrive_sync.sh` | Syncs local backups to Google Drive via rclone |

### Windows (`Scripts/windows/`)

| Script | Description |
|--------|-------------|
| `Create-ADUsers.ps1` | Creates 5 domain users in Active Directory |
| `Create-ADGroups.ps1` | Creates security groups in the StrongMind OU |
| `Add-UsersToGroups.ps1` | Assigns users to their respective groups |
| `Get-ADEvents.ps1` | Queries security logs for user creation/modification events |
| `Create-FileShare.ps1` | Creates an SMB share accessible from Linux |
| `Check-Updates.ps1` | Checks for pending Windows updates and generates a report |

---

## Quick Start

```bash
# Clone the repo
git clone https://github.com/Mahdi-196/Systems-Administrator-1-Exercise.git
cd Systems-Administrator-1-Exercise

# Linux scripts
cd Scripts/linux
chmod +x *.sh
sudo bash create_users.sh

# Windows scripts (copy to C:\Scripts via SCP, then run in PowerShell)
.\Create-ADUsers.ps1
```

---

## Requirements

- Oracle VirtualBox
- Ubuntu Server 22.04 LTS
- Windows Server 2022 Evaluation
