# Assign users to Active Directory groups

Import-Module ActiveDirectory

$Assignments = @{
    "Teachers"  = @("jsmith", "mgarcia")
    "Students"  = @("twilliams", "alee")
    "Staff"     = @("bjohnson")
    "All_Staff" = @("jsmith", "mgarcia", "twilliams", "alee", "bjohnson")
}

foreach ($Group in $Assignments.Keys) {
    foreach ($User in $Assignments[$Group]) {
        try {
            Add-ADGroupMember -Identity $Group -Members $User -ErrorAction Stop
            Write-Host "[OK] $User -> $Group"
        } catch {
            Write-Host "[SKIP] $User already in $Group"
        }
    }
}
