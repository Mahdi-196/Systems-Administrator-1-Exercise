# Query Active Directory security events for user changes

Write-Host "========================================"
Write-Host "AD EVENT REPORT - $(Get-Date)"
Write-Host "========================================"

Write-Host "`n-- User Creation Events (4720) --"
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4720} -MaxEvents 10 -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, @{N='User';E={$_.Properties[0].Value}} |
    Format-Table -AutoSize

Write-Host "`n-- User Modification Events (4738) --"
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4738} -MaxEvents 10 -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, @{N='User';E={$_.Properties[0].Value}} |
    Format-Table -AutoSize

Write-Host "`n-- AD Users in StrongMind OU --"
Get-ADUser -Filter * -SearchBase "OU=StrongMind,DC=strongmind,DC=local" -Properties Created |
    Select-Object Name, SamAccountName, Created |
    Format-Table -AutoSize
