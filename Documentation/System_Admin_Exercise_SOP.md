# Systems Administrator Exercise
## Standard Operating Procedure

**Version:** 3.0
**Classification:** Training Documentation

---

## Quick Reference

| VM | SSH Port | Username | Password |
|----|----------|----------|----------|
| Ubuntu Server | 2222 | sysadmin | `<your-password>` |
| Windows Server | 2223 | Administrator | `Pass1!` |
| AD Domain Users | - | STRONGMIND\\* | `TempPass123!` |

---

# Part A: Linux Server Administration

## 1. Connect to Ubuntu VM

```bash
ssh -p 2222 sysadmin@localhost
```

---

## 2. Repository Setup

```bash
git clone https://github.com/Mahdi-196/Systems-Administrator-1-Exercise.git
cd Systems-Administrator-1-Exercise/Scripts/linux
chmod +x *.sh
```

---

## 3. Create Users

**Before:**
```bash
awk -F: '$3 >= 1000 {print $1}' /etc/passwd
```

**Execute:**
```bash
sudo bash create_users.sh
```

**Verify:**
```bash
awk -F: '$3 >= 1000 {print $1}' /etc/passwd
```

---

## 4. Create Groups

**Before:**
```bash
grep -E "^(Teachers|Students|Staff|All_Staff):" /etc/group || echo "No groups found"
```

**Execute:**
```bash
sudo bash create_groups.sh
```

**Verify:**
```bash
grep -E "^(Teachers|Students|Staff|All_Staff):" /etc/group
```

---

## 5. Login Verification

Test each user login (default password: `TempPass123!`):

```bash
sudo su - jsmith
sudo su - mgarcia
sudo su - twilliams
sudo su - alee
sudo su - bjohnson
```

---

## 6. User Activity Report

```bash
sudo bash user_activity.sh
```

---

## 7. Local Backup (Rsync)

**Setup test data:**
```bash
mkdir -p ~/important_files ~/backup_destination
echo "Test document $(date)" > ~/important_files/test.txt
echo "Another file" > ~/important_files/file2.txt
echo "Important data" > ~/important_files/data.txt
```

**Run backup:**
```bash
bash rsync_backup.sh
```

**Verify:**
```bash
ls -la ~/backup_destination/
cat ~/rsync_backup.log
```

---

## 8. Schedule Backup (Cron)

**Add cron job:**
```bash
(crontab -l 2>/dev/null; echo "0 2 * * * $HOME/Systems-Administrator-1-Exercise/Scripts/linux/rsync_backup.sh >> $HOME/cron_backup.log 2>&1") | crontab -
```

**Verify:**
```bash
crontab -l
```

---

## 9. Google Drive Integration

**Install rclone:**
```bash
sudo apt update && sudo apt install rclone -y
```

**Configure:**
```bash
rclone config
```
- Select: `n` (new remote)
- Name: `gdrive`
- Storage: `drive` (Google Drive)
- Advanced config: `n`
- Auto config: `n`
- Team drive: `n`

**Mount:**
```bash
mkdir -p ~/gdrive
rclone mount gdrive: ~/gdrive --daemon
```

---

## 10. Cloud Sync

```bash
bash gdrive_sync.sh
cat ~/gdrive_sync.log
```

---

## 11. Final Verification (Linux)

```bash
echo "Users: $(awk -F: '$3 >= 1000 {print $1}' /etc/passwd | tr '\n' ' ')"
echo "Groups: $(grep -E '^(Teachers|Students|Staff|All_Staff):' /etc/group | cut -d: -f1 | tr '\n' ' ')"
echo "Cron: $(crontab -l | grep rsync)"
echo "Backups: $(ls ~/backup_destination/)"
```

---

# Part B: Windows Server Administration

## 1. Install Windows Server

1. Boot from Windows Server 2022 ISO
2. Select **Windows Server 2022 Standard Evaluation (Desktop Experience)**
3. Set Administrator password: `Pass1!`

---

## 2. Configure Active Directory Domain

**In Server Manager:**

1. Click **Add roles and features**
2. Next → Next → Next → Check **Active Directory Domain Services**
3. **Add Features** → Next → Next → **Install**
4. Wait for completion
5. Click **yellow flag** → **Promote this server to a domain controller**
6. Select **Add a new forest** → Domain: `strongmind.local`
7. DSRM password: `Pass1!`
8. Next through everything → **Install**
9. Server reboots automatically
10. Login as: `STRONGMIND\Administrator` / `Pass1!`
11. **Wait 3-5 minutes** for AD services to start

**Verify:**
```powershell
Get-ADDomain
```

---

## 3. Enable SSH

**In Windows PowerShell:**

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
mkdir C:\Scripts
```

---

## 4. Transfer Scripts

**On host machine (new terminal):**

```bash
ssh-keygen -f "$HOME/.ssh/known_hosts" -R '[localhost]:2223'
scp -P 2223 <path-to-scripts>/*.ps1 Administrator@localhost:C:/Scripts/
```

---

## 5. SSH into Windows

```bash
ssh -p 2223 Administrator@localhost
```

Then type:
```
powershell
```

---

## 6. Run AD Setup Scripts

```powershell
cd C:\Scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

**Create OU:**
```powershell
New-ADOrganizationalUnit -Name "StrongMind" -Path "DC=strongmind,DC=local"
```

**Run scripts:**
```powershell
.\Create-ADUsers.ps1
.\Create-ADGroups.ps1
.\Add-UsersToGroups.ps1
.\Get-ADEvents.ps1
```

---

## 7. Create File Share

```powershell
.\Create-FileShare.ps1
```

---

## 8. Create Scheduled Task

```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Scripts\Check-Updates.ps1"
```

```powershell
$trigger = New-ScheduledTaskTrigger -Daily -At "6:00AM"
```

```powershell
Register-ScheduledTask -TaskName "DailyUpdateCheck" -Action $action -Trigger $trigger -User "SYSTEM" -RunLevel Highest
```

---

# Part C: Cross-Platform Integration

## 1. Get Windows Host-Only IP

**On Windows:**
```powershell
Get-NetIPAddress -AddressFamily IPv4 | Select-Object IPAddress, InterfaceAlias
```

Note the `192.168.56.x` address.

---

## 2. Mount Windows Share from Linux

**On Ubuntu VM:**

```bash
sudo mkdir -p /mnt/windows_share
```

```bash
sudo mount -t cifs //192.168.56.X/SharedFiles /mnt/windows_share -o 'username=Administrator,password=Pass1!'
```

> **Important:** Use single quotes around the `-o` options to prevent bash from interpreting `!`

---

## 3. Create File from Linux

```bash
sudo touch /mnt/windows_share/created_from_linux.txt
ls /mnt/windows_share
```

---

## 4. Verify on Windows

```powershell
Get-ChildItem C:\SharedFiles
```

Should show `created_from_linux.txt`

---

# Final Verification Checklist

## Windows Server

```powershell
Get-ADUser -Filter * -SearchBase "OU=StrongMind,DC=strongmind,DC=local" | Select-Object Name
Get-ADGroup -Filter * -SearchBase "OU=StrongMind,DC=strongmind,DC=local" | Select-Object Name
Get-SmbShare | Where-Object {$_.Name -eq "SharedFiles"}
Get-ScheduledTask -TaskName "DailyUpdateCheck"
Get-ChildItem C:\SharedFiles
```

## Ubuntu Server

```bash
awk -F: '$3 >= 1000 {print $1}' /etc/passwd
grep -E "^(Teachers|Students|Staff|All_Staff):" /etc/group
crontab -l | grep rsync
ls ~/backup_destination/
```

---

# Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| `-bash: !...: event not found` | `!` triggers bash history | Use single quotes: `-o 'username=...,password=Pass1!'` |
| `Connection refused` on mount | VMs can't see each other | Use Host-Only IP (192.168.56.x), not NAT IP |
| Commands split across lines | Terminal wrapping | Type manually or widen terminal |
| `AD Web Services not running` | AD not fully started | Wait 3-5 minutes after AD reboot |
| `Unable to find default server` | Same as above | Restart-Service ADWS or reboot |

---

# Network Configuration

| Network Type | Purpose | IP Range |
|--------------|---------|----------|
| NAT | Internet access | 10.0.2.x |
| Host-Only | VM-to-VM communication | 192.168.56.x |

**Important:** Cross-platform file sharing requires Host-Only networking. NAT IPs (10.0.2.x) cannot be used for VM-to-VM communication.

---

**End of Document**
