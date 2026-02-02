# StrongMind System Admin Scripts

Automation scripts for Ubuntu Server 22.04 and Windows Server 2022 infrastructure deployment.

## Structure

```
Scripts/
├── linux/
│   ├── create_users.sh      # Create organizational users
│   ├── create_groups.sh     # Create groups and assign users
│   ├── user_activity.sh     # Generate activity report from logs
│   ├── rsync_backup.sh      # Incremental local backup
│   └── gdrive_sync.sh       # Sync backups to Google Drive
│
└── windows/
    ├── Create-ADUsers.ps1       # Create AD domain users
    ├── Create-ADGroups.ps1      # Create AD security groups
    ├── Add-UsersToGroups.ps1    # Assign users to groups
    ├── Get-ADEvents.ps1         # Query AD security events
    ├── Check-Updates.ps1        # Windows Update status report
    └── Create-FileShare.ps1     # Create SMB share for Linux access
```

## Linux Scripts

**Prerequisites:** Ubuntu Server 22.04 with sudo access

```bash
# Make executable
chmod +x linux/*.sh

# Run as root
sudo ./linux/create_users.sh
sudo ./linux/create_groups.sh
sudo ./linux/user_activity.sh
./linux/rsync_backup.sh
./linux/gdrive_sync.sh  # Requires rclone configured
```

## Windows Scripts

**Prerequisites:** Windows Server 2022 with AD DS role, run as Administrator

```powershell
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run scripts
.\windows\Create-ADUsers.ps1
.\windows\Create-ADGroups.ps1
.\windows\Add-UsersToGroups.ps1
.\windows\Get-ADEvents.ps1
.\windows\Check-Updates.ps1
.\windows\Create-FileShare.ps1
```

## Configuration

| Setting | Value |
|---------|-------|
| Domain | strongmind.local |
| OU | OU=StrongMind,DC=strongmind,DC=local |
| Default Password | TempPass123! (expires on first login) |

## Users Created

| Username | Full Name | Groups |
|----------|-----------|--------|
| jsmith | John Smith | Teachers, All_Staff |
| mgarcia | Maria Garcia | Teachers, All_Staff |
| twilliams | Tom Williams | Students, All_Staff |
| alee | Alice Lee | Students, All_Staff |
| bjohnson | Bob Johnson | Staff, All_Staff |

## License

MIT
