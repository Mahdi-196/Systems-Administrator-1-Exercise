# StrongMind Infrastructure Deployment & Configuration Guide
## Dual-Platform Server Environment
### Ubuntu Server 22.04 LTS & Windows Server 2022 Active Directory

**Document Version:** 2.0
**Date Created:** February 1, 2026
**Author:** Mahdi Ghaleb
**Classification:** Enterprise Infrastructure Documentation

**Repository:** [github.com/mahdighaleb/strongmind-sysadmin-exercise](https://github.com/mahdighaleb/strongmind-sysadmin-exercise)

---

## Table of Contents

1. [Purpose](#1-purpose)
2. [Scope](#2-scope)
3. [Prerequisites](#3-prerequisites)
4. [Part A: Ubuntu Server Configuration](#4-part-a-ubuntu-server-configuration)
5. [Part B: Windows Server Configuration](#5-part-b-windows-server-configuration)
6. [Part C: Cross-Platform Integration](#6-part-c-cross-platform-integration)
7. [Encountered Issues & Resolutions](#7-encountered-issues--resolutions)
8. [Verification Checklist](#8-verification-checklist)
9. [Security Considerations](#9-security-considerations)
10. [Credentials Reference](#10-credentials-reference)
11. [Appendix: Script Source Code](#11-appendix-script-source-code)

---

## 1. Purpose

This document details the standardized deployment procedure for StrongMind's educational infrastructure. It establishes a scalable, cross-platform environment connecting Ubuntu Linux servers with Windows Active Directory to support secure file sharing and automated data protection.

**Key Deliverables:**
- Centralized user and group management
- Automated backup solutions with cloud integration
- Active Directory domain services
- Cross-platform resource sharing
- Scheduled maintenance automation

---

## 2. Scope

| Component | Technology |
|-----------|------------|
| Virtualization | Oracle VirtualBox |
| Linux Server | Ubuntu Server 22.04 LTS |
| Windows Server | Windows Server 2022 with AD DS |
| File Sharing | SMB/CIFS Protocol |
| Automation | Bash, PowerShell, Cron, Task Scheduler |
| Cloud Storage | Google Drive via rclone |

---

## 3. Prerequisites

### 3.1 Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 16 GB | 32 GB |
| Processor | Intel i5 / AMD equivalent | Intel i7 / AMD Ryzen 7 |
| Storage | 60 GB available | 120 GB SSD |

### 3.2 Software Requirements

- Oracle VirtualBox (latest stable version)
- Ubuntu Server 22.04 LTS ISO
- Windows Server 2022 Evaluation ISO
- Google Workspace account (for cloud storage integration)

### 3.3 Network Configuration

| Network Type | Purpose | IP Range |
|--------------|---------|----------|
| NAT | Internet access | 10.0.2.x |
| Host-Only | Inter-VM communication | 192.168.56.x |

---

## 4. Part A: Ubuntu Server Configuration

### 4.1 Virtual Machine Provisioning

**Objective:** Create Ubuntu Server VM with dual networking.

**Execution:**
```bash
VBoxManage createvm --name "Ubuntu-Server" --ostype Ubuntu_64 --register
VBoxManage modifyvm "Ubuntu-Server" --memory 2048 --cpus 2 --nic1 nat --nic2 hostonly
VBoxManage createmedium disk --filename "Ubuntu-Server.vdi" --size 25000
VBoxManage modifyvm "Ubuntu-Server" --natpf1 "ssh,tcp,,2222,,22"
```

**Verification:** VM appears in VirtualBox Manager with correct specifications.

---

### 4.2 Operating System Installation

**Objective:** Install Ubuntu Server with SSH enabled.

**Procedure:**
1. Boot from Ubuntu Server 22.04 ISO
2. Select "Try or Install Ubuntu Server"
3. Configure: Username `sysadmin`, enable OpenSSH server
4. Complete installation and reboot

**Verification:** SSH connection successful.
```bash
ssh -p 2222 sysadmin@localhost
```

---

### 4.3 User Creation Automation

**Objective:** Create 5 organizational users with forced password rotation.

| Script | Location | Reference |
|--------|----------|-----------|
| `create_users.sh` | `/home/sysadmin/` | [Appendix A](#appendix-a-user-creation-script) |

**Execution:**
```bash
chmod +x create_users.sh
sudo bash create_users.sh
```

**Verification:**
```bash
tail -n 6 /etc/passwd
```

**Expected Output:** Users jsmith, mgarcia, twilliams, alee, bjohnson created.

---

### 4.4 Group Creation and Assignment

**Objective:** Create organizational groups and assign user memberships.

| Script | Location | Reference |
|--------|----------|-----------|
| `create_groups.sh` | `/home/sysadmin/` | [Appendix B](#appendix-b-group-creation-script) |

**Execution:**
```bash
chmod +x create_groups.sh
sudo bash create_groups.sh
```

**Verification:**
```bash
groups jsmith
groups twilliams
```

**Expected Output:**
- `jsmith : jsmith Teachers All_Staff`
- `twilliams : twilliams Students All_Staff`

---

### 4.5 User Activity Monitoring

**Objective:** Generate reports from authentication logs.

| Script | Location | Reference |
|--------|----------|-----------|
| `user_activity.sh` | `/home/sysadmin/` | [Appendix C](#appendix-c-user-activity-script) |

**Execution:**
```bash
sudo bash user_activity.sh
```

**Output:** Report showing recent logins, active sessions, failed attempts, and account modifications.

---

### 4.6 Automated Backup (Rsync)

**Objective:** Implement incremental backup with logging.

| Script | Location | Reference |
|--------|----------|-----------|
| `rsync_backup.sh` | `/home/sysadmin/` | [Appendix D](#appendix-d-rsync-backup-script) |

**Setup:**
```bash
mkdir -p ~/important_files ~/backup_destination
echo "Test Document" > ~/important_files/doc1.txt
```

**Execution:**
```bash
bash rsync_backup.sh
```

**Verification:**
```bash
ls ~/backup_destination
cat ~/rsync_backup.log
```

---

### 4.7 Cron Job Configuration

**Objective:** Schedule daily backup at 2:00 AM.

**Execution:**
```bash
crontab -e
```

**Add Entry:**
```
0 2 * * * /home/sysadmin/rsync_backup.sh >> /home/sysadmin/cron_backup.log 2>&1
```

**Verification:**
```bash
crontab -l
```

---

### 4.8 Google Drive Integration

**Objective:** Mount cloud storage for offsite backups.

> **Note:** Default rclone OAuth credentials are blocked. Custom credentials required.

**Prerequisites:**
1. Create Google Cloud project at [console.cloud.google.com](https://console.cloud.google.com)
2. Enable Google Drive API
3. Create OAuth 2.0 Desktop credentials
4. Add your email as test user

**Execution:**
```bash
sudo apt update && sudo apt install rclone -y
rclone config
mkdir -p ~/gdrive
rclone mount gdrive: ~/gdrive --daemon
```

**Cloud Sync Script:** See [Appendix E](#appendix-e-google-drive-sync-script)

**Verification:**
```bash
ls ~/gdrive
rclone ls gdrive:Backups/
```

---

## 5. Part B: Windows Server Configuration

### 5.1 Virtual Machine Provisioning

**Objective:** Create Windows Server VM with adequate resources for AD DS.

**Execution:**
```bash
VBoxManage createvm --name "Windows-Server-2022" --ostype Windows2022_64 --register
VBoxManage modifyvm "Windows-Server-2022" --memory 4096 --cpus 2 --nic1 nat --nic2 hostonly
VBoxManage createmedium disk --filename "Windows-Server-2022.vdi" --size 50000
VBoxManage controlvm "Windows-Server-2022" natpf1 "ssh,tcp,,2223,,22"
```

---

### 5.2 Operating System Installation

**Objective:** Install Windows Server with Desktop Experience.

**Procedure:**
1. Boot from Windows Server 2022 ISO
2. Select **"Windows Server 2022 Standard Evaluation (Desktop Experience)"**
3. Complete installation, set Administrator password

---

### 5.3 Enable SSH Remote Access

**Objective:** Enable remote PowerShell administration.

**Execution (in PowerShell):**
```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
```

**Connect:**
```bash
ssh -p 2223 Administrator@localhost
powershell
```

---

### 5.4 Active Directory Domain Services

**Objective:** Promote server to domain controller for `strongmind.local`.

**Procedure:**
1. Server Manager → Add Roles and Features
2. Select **Active Directory Domain Services**
3. Click notification flag → "Promote this server to a domain controller"
4. Select "Add a new forest" → Domain: `strongmind.local`
5. Set DSRM password → Complete wizard

**Post-restart Login:** `STRONGMIND\Administrator`

---

### 5.5 Create Organizational Unit

**Execution:**
```powershell
Import-Module ActiveDirectory
New-ADOrganizationalUnit -Name "StrongMind" -Path "DC=strongmind,DC=local"
```

---

### 5.6 Domain User Creation

**Objective:** Create 5 domain users via PowerShell.

See [Appendix F](#appendix-f-ad-user-creation-powershell) for full script.

**Execution:**
```powershell
$pw = ConvertTo-SecureString "TempPass123!" -AsPlainText -Force
$ou = "OU=StrongMind,DC=strongmind,DC=local"

New-ADUser -Name "John Smith" -SamAccountName "jsmith" -Path $ou -AccountPassword $pw -Enabled $true
# Repeat for remaining users...
```

**Verification:**
```powershell
Get-ADUser -Filter * -SearchBase $ou | Select Name
```

---

### 5.7 Domain Group Creation

**Execution:**
```powershell
New-ADGroup -Name "Teachers" -GroupScope Global -Path $ou
New-ADGroup -Name "Students" -GroupScope Global -Path $ou
New-ADGroup -Name "Staff" -GroupScope Global -Path $ou
New-ADGroup -Name "All_Staff" -GroupScope Global -Path $ou
```

---

### 5.8 Group Membership Assignment

**Execution:**
```powershell
Add-ADGroupMember -Identity "Teachers" -Members jsmith,mgarcia
Add-ADGroupMember -Identity "Students" -Members twilliams,alee
Add-ADGroupMember -Identity "Staff" -Members bjohnson
Add-ADGroupMember -Identity "All_Staff" -Members jsmith,mgarcia,twilliams,alee,bjohnson
```

**Verification:**
```powershell
Get-ADGroupMember "Teachers" | Select Name
```

---

### 5.9 Active Directory Event Logging

**Objective:** Query security events for user modifications.

**Execution:**
```powershell
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4720} -MaxEvents 10 | Select TimeCreated, Message
```

**Alternative:**
```powershell
Get-ADUser -Filter * -SearchBase $ou -Properties Created | Select Name, Created
```

---

### 5.10 SMB File Share Creation

**Objective:** Create network share accessible from Linux.

**Execution:**
```powershell
New-Item -Path "C:\SharedFiles" -ItemType Directory -Force
Set-Content -Path "C:\SharedFiles\test.txt" -Value "Hello from Windows Server"
New-SmbShare -Name "SharedFiles" -Path "C:\SharedFiles" -FullAccess "Everyone"
Grant-SmbShareAccess -Name "SharedFiles" -AccountName "Everyone" -AccessRight Full -Force
icacls "C:\SharedFiles" /grant Everyone:F
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
```

**Verification:**
```powershell
Get-SmbShare | Where-Object {$_.Name -eq "SharedFiles"}
```

---

### 5.11 Scheduled Update Check

**Objective:** Automate Windows Update monitoring.

See [Appendix G](#appendix-g-windows-update-check-script) for full script.

**Execution:**
```powershell
New-Item -Path "C:\Scripts" -ItemType Directory -Force
# Create script content (see Appendix G)
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Scripts\Check-Updates.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "6:00AM"
Register-ScheduledTask -TaskName "DailyUpdateCheck" -Action $action -Trigger $trigger -User "SYSTEM"
```

**Verification:**
```powershell
Get-ScheduledTask -TaskName "DailyUpdateCheck"
```

---

## 6. Part C: Cross-Platform Integration

### 6.1 Configure Host-Only Networking

**Objective:** Enable inter-VM communication.

**Execution:**
```bash
VBoxManage controlvm "Ubuntu-Server" poweroff
VBoxManage controlvm "Windows-Server-2022" poweroff
VBoxManage modifyvm "Ubuntu-Server" --nic2 hostonly --hostonlyadapter2 vboxnet0
VBoxManage modifyvm "Windows-Server-2022" --nic2 hostonly --hostonlyadapter2 vboxnet0
VBoxManage startvm "Ubuntu-Server"
VBoxManage startvm "Windows-Server-2022"
```

---

### 6.2 Configure Network Interfaces

**Ubuntu:**
```bash
sudo ip link set enp0s8 up
sudo dhclient enp0s8
ip addr show enp0s8
```

**Windows:**
```powershell
ipconfig
```

> **Note:** Record IPv4 address for Host-Only adapter (192.168.56.x). DHCP may assign different addresses on reboot.

---

### 6.3 Mount Windows Share from Linux

**Execution:**
```bash
sudo apt install cifs-utils -y
sudo mkdir -p /mnt/windows_share
sudo mount -t cifs //<Windows_IP>/SharedFiles /mnt/windows_share \
    -o 'username=Administrator,password=<password>,domain=STRONGMIND'
```

---

### 6.4 Verify Cross-Platform Access

**Ubuntu - Create file:**
```bash
sudo touch /mnt/windows_share/created_from_linux.txt
ls /mnt/windows_share
```

**Windows - Verify:**
```powershell
Get-ChildItem C:\SharedFiles
```

**Expected:** Both `test.txt` and `created_from_linux.txt` visible on both systems.

---

## 7. Encountered Issues & Resolutions

| # | Error | Cause | Resolution |
|---|-------|-------|------------|
| 1 | `Syntax error: "(" unexpected` | Script run with `sh` instead of `bash` | Use `bash script.sh` explicitly |
| 2 | `'Import-Module' not recognized` | SSH connects to CMD, not PowerShell | Type `powershell` after SSH |
| 3 | `Authentication token manipulation error` | Password expiration enforced | `sudo chage -d -1 username` |
| 4 | `Access blocked: rclone's request is invalid` | Default OAuth credentials blocked | Create custom Google Cloud credentials |
| 5 | `mount error(111): Connection refused` | Both VMs have same NAT IP | Add Host-Only network adapter |
| 6 | `-bash: !,domain=...: event not found` | `!` triggers history expansion | Wrap options in single quotes |
| 7 | `mount error(13): Permission denied` | Insufficient share permissions | `Grant-SmbShareAccess` + `icacls /grant` |
| 8 | `Missing argument for parameter 'Path'` | Long commands split via SSH | Use variables to shorten commands |

---

## 8. Verification Checklist

### Ubuntu Server

| Task | Command | Expected |
|------|---------|----------|
| Users created | `tail -n 6 /etc/passwd` | 5 users listed |
| Groups created | `grep -E "Teachers\|Students" /etc/group` | 4 groups |
| Cron active | `crontab -l` | Backup schedule shown |
| Drive mounted | `ls ~/gdrive` | Drive contents visible |

### Windows Server

| Task | Command | Expected |
|------|---------|----------|
| AD Users | `Get-ADUser -Filter * -SearchBase $ou` | 5 users |
| AD Groups | `Get-ADGroup -Filter * -SearchBase $ou` | 4 groups |
| File share | `Get-SmbShare` | SharedFiles listed |
| Scheduled task | `Get-ScheduledTask -TaskName "DailyUpdateCheck"` | Task exists |

### Cross-Platform

| Task | Verification | Expected |
|------|--------------|----------|
| Network | `ping 192.168.56.x` | 0% packet loss |
| Share mount | `ls /mnt/windows_share` | Files visible |
| Cross-write | Check both systems | Linux-created file appears on Windows |

---

## 9. Security Considerations

> **Security Notice:** Credentials in this document are for **training purposes only**. Production environments require:
>
> - Minimum 14-character passwords with complexity requirements
> - No plain-text credential storage
> - Certificate-based or MFA authentication
> - Principle of least privilege for file shares
> - Regular credential rotation via Group Policy

### Production Recommendations

1. Implement password policies via Group Policy
2. Enable comprehensive security auditing
3. Isolate servers on dedicated VLANs
4. Encrypt backups at rest and in transit
5. Restrict SMB access to specific IP ranges

---

## 10. Credentials Reference

| System | Username | Password | Role |
|--------|----------|----------|------|
| Ubuntu | sysadmin | common | Administrator |
| Ubuntu | jsmith | Pass1 | Teacher |
| Ubuntu | mgarcia, twilliams, alee, bjohnson | common | Staff/Students |
| Windows | Administrator | Pass1 | Domain Admin |
| AD Domain | STRONGMIND\\* | TempPass123! | Domain Users |

---

## 11. Appendix: Script Source Code

All scripts are available in the repository: **[github.com/mahdighaleb/strongmind-sysadmin-exercise](https://github.com/mahdighaleb/strongmind-sysadmin-exercise)**

---

### Appendix A: User Creation Script

**File:** `create_users.sh`

```bash
#!/bin/bash
#================================================================
# USER CREATION SCRIPT
# Purpose: Automate user provisioning for StrongMind organization
# Author: Mahdi Ghaleb
#================================================================

echo "======================================"
echo "    USER CREATION SCRIPT"
echo "    Executed: $(date)"
echo "======================================"

# Create user accounts
sudo useradd -m -s /bin/bash -c "John Smith" jsmith
sudo useradd -m -s /bin/bash -c "Maria Garcia" mgarcia
sudo useradd -m -s /bin/bash -c "Tom Williams" twilliams
sudo useradd -m -s /bin/bash -c "Alice Lee" alee
sudo useradd -m -s /bin/bash -c "Bob Johnson" bjohnson

# Set passwords and enforce change on first login
for user in jsmith mgarcia twilliams alee bjohnson; do
    echo "$user:TempPass123!" | sudo chpasswd
    sudo chage -d 0 $user  # Force password change
    echo "[OK] Created user: $user"
done

echo "======================================"
echo "    Complete! Users must change password on first login."
echo "======================================"
```

---

### Appendix B: Group Creation Script

**File:** `create_groups.sh`

```bash
#!/bin/bash
#================================================================
# GROUP CREATION SCRIPT
# Purpose: Create organizational groups and assign users
# Author: Mahdi Ghaleb
#================================================================

echo "======================================"
echo "    GROUP CREATION SCRIPT"
echo "======================================"

# Create groups
sudo groupadd Teachers && echo "[OK] Created: Teachers"
sudo groupadd Students && echo "[OK] Created: Students"
sudo groupadd Staff && echo "[OK] Created: Staff"
sudo groupadd All_Staff && echo "[OK] Created: All_Staff"

# Assign users
sudo usermod -aG Teachers,All_Staff jsmith
sudo usermod -aG Teachers,All_Staff mgarcia
sudo usermod -aG Students,All_Staff twilliams
sudo usermod -aG Students,All_Staff alee
sudo usermod -aG Staff,All_Staff bjohnson

echo "[OK] Users assigned to groups"
echo "======================================"
```

---

### Appendix C: User Activity Script

**File:** `user_activity.sh`

```bash
#!/bin/bash
#================================================================
# USER ACTIVITY REPORT
# Purpose: Aggregate user activity from system logs
# Author: Mahdi Ghaleb
#================================================================

echo "======================================"
echo "    USER ACTIVITY REPORT"
echo "    Generated: $(date)"
echo "    Server: $(hostname)"
echo "======================================"

echo ""
echo "--- RECENT LOGIN HISTORY ---"
last -n 10

echo ""
echo "--- CURRENTLY ACTIVE SESSIONS ---"
who

echo ""
echo "--- FAILED AUTHENTICATION ATTEMPTS ---"
sudo grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || echo "None found"

echo ""
echo "--- USER ACCOUNT MODIFICATIONS ---"
sudo grep -E "useradd|usermod|groupadd" /var/log/auth.log 2>/dev/null | tail -5 || echo "None found"

echo "======================================"
```

---

### Appendix D: Rsync Backup Script

**File:** `rsync_backup.sh`

```bash
#!/bin/bash
#================================================================
# RSYNC BACKUP SCRIPT
# Purpose: Incremental backup of critical data
# Author: Mahdi Ghaleb
#================================================================

SOURCE="/home/sysadmin/important_files/"
DESTINATION="/home/sysadmin/backup_destination/"
LOGFILE="/home/sysadmin/rsync_backup.log"

echo "======================================"
echo "    RSYNC BACKUP - $(date)"
echo "======================================" | tee -a "$LOGFILE"

rsync -avh --progress "$SOURCE" "$DESTINATION" 2>&1 | tee -a "$LOGFILE"

echo "Backup completed: $(date)" | tee -a "$LOGFILE"
```

---

### Appendix E: Google Drive Sync Script

**File:** `rsync_to_gdrive.sh`

```bash
#!/bin/bash
#================================================================
# GOOGLE DRIVE SYNC SCRIPT
# Purpose: Sync local backups to cloud storage
# Author: Mahdi Ghaleb
#================================================================

SOURCE="/home/sysadmin/important_files/"
DESTINATION="gdrive:Backups/ubuntu_server/"
LOGFILE="/home/sysadmin/gdrive_sync.log"

echo "======================================"
echo "    GOOGLE DRIVE SYNC - $(date)"
echo "======================================" | tee -a "$LOGFILE"

rclone sync "$SOURCE" "$DESTINATION" -v 2>&1 | tee -a "$LOGFILE"

echo "Sync completed: $(date)" | tee -a "$LOGFILE"
```

---

### Appendix F: AD User Creation (PowerShell)

**File:** `Create-ADUsers.ps1`

```powershell
#================================================================
# ACTIVE DIRECTORY USER CREATION
# Purpose: Automate domain user provisioning
# Author: Mahdi Ghaleb
#================================================================

Import-Module ActiveDirectory

$pw = ConvertTo-SecureString "TempPass123!" -AsPlainText -Force
$ou = "OU=StrongMind,DC=strongmind,DC=local"

$Users = @(
    @{Name="John Smith"; SAM="jsmith"},
    @{Name="Maria Garcia"; SAM="mgarcia"},
    @{Name="Tom Williams"; SAM="twilliams"},
    @{Name="Alice Lee"; SAM="alee"},
    @{Name="Bob Johnson"; SAM="bjohnson"}
)

foreach ($User in $Users) {
    New-ADUser -Name $User.Name `
        -SamAccountName $User.SAM `
        -Path $ou `
        -AccountPassword $pw `
        -Enabled $true
    Write-Host "[OK] Created: $($User.SAM)"
}
```

---

### Appendix G: Windows Update Check Script

**File:** `Check-Updates.ps1`

```powershell
#================================================================
# WINDOWS UPDATE CHECK SCRIPT
# Purpose: Query pending updates and generate report
# Method: COM Object (native - no external modules required)
# Author: Mahdi Ghaleb
#================================================================

$ReportPath = "C:\Scripts\UpdateReport.txt"

"======================================" | Out-File $ReportPath
"    WINDOWS UPDATE STATUS REPORT"      | Out-File $ReportPath -Append
"    Generated: $(Get-Date)"            | Out-File $ReportPath -Append
"======================================" | Out-File $ReportPath -Append

try {
    $Session = New-Object -ComObject Microsoft.Update.Session
    $Searcher = $Session.CreateUpdateSearcher()
    $Result = $Searcher.Search("IsInstalled=0")

    if ($Result.Updates.Count -eq 0) {
        "No pending updates. System is current." | Out-File $ReportPath -Append
    } else {
        "Found $($Result.Updates.Count) pending update(s):" | Out-File $ReportPath -Append
        $Result.Updates | Select-Object Title, MsrcSeverity | Out-File $ReportPath -Append
    }
} catch {
    "Error: $($_.Exception.Message)" | Out-File $ReportPath -Append
}

"======================================" | Out-File $ReportPath -Append
```

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-01 | Mahdi Ghaleb | Initial creation |
| 1.1 | 2026-02-01 | Mahdi Ghaleb | Security considerations, fixed Windows Update script |
| 2.0 | 2026-02-01 | Mahdi Ghaleb | Restructured with Appendix format, added repository link |

---

*This document is maintained as part of the StrongMind Infrastructure Documentation Library.*

**End of Document**
