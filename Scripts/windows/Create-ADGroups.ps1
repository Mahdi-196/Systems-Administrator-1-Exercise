# Create Active Directory security groups

Import-Module ActiveDirectory

$OU = "OU=StrongMind,DC=strongmind,DC=local"
$Groups = @("Teachers", "Students", "Staff", "All_Staff")

foreach ($Group in $Groups) {
    try {
        New-ADGroup -Name $Group -GroupScope Global -GroupCategory Security -Path $OU
        Write-Host "[OK] $Group"
    } catch {
        Write-Host "[SKIP] $Group exists"
    }
}
