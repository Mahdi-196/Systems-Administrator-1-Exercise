# Create SMB file share accessible from Linux

$SharePath = "C:\SharedFiles"
$ShareName = "SharedFiles"

# Create directory
New-Item -Path $SharePath -ItemType Directory -Force | Out-Null

# Create test file
Set-Content -Path "$SharePath\test.txt" -Value "Shared from Windows Server - $(Get-Date)"

# Create SMB share
if (!(Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name $ShareName -Path $SharePath -FullAccess "Everyone"
    Write-Host "[OK] Share created: \\$env:COMPUTERNAME\$ShareName"
} else {
    Write-Host "[SKIP] Share already exists"
}

# Set permissions
Grant-SmbShareAccess -Name $ShareName -AccountName "Everyone" -AccessRight Full -Force | Out-Null
icacls $SharePath /grant "Everyone:F" /Q

# Enable firewall rules
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing" -ErrorAction SilentlyContinue

Write-Host "[OK] Share ready at: \\$((Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.PrefixOrigin -eq 'Dhcp'}).IPAddress)\$ShareName"
