# Create Active Directory users in StrongMind OU

Import-Module ActiveDirectory

$Password = ConvertTo-SecureString "TempPass123!" -AsPlainText -Force
$OU = "OU=StrongMind,DC=strongmind,DC=local"

$Users = @(
    @{Name="John Smith"; SAM="jsmith"},
    @{Name="Maria Garcia"; SAM="mgarcia"},
    @{Name="Tom Williams"; SAM="twilliams"},
    @{Name="Alice Lee"; SAM="alee"},
    @{Name="Bob Johnson"; SAM="bjohnson"}
)

foreach ($User in $Users) {
    try {
        New-ADUser -Name $User.Name `
            -SamAccountName $User.SAM `
            -UserPrincipalName "$($User.SAM)@strongmind.local" `
            -Path $OU `
            -AccountPassword $Password `
            -Enabled $true `
            -ChangePasswordAtLogon $true
        Write-Host "[OK] $($User.SAM)"
    } catch {
        Write-Host "[SKIP] $($User.SAM) - $($_.Exception.Message)"
    }
}
