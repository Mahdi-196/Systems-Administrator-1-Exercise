# Check for pending Windows Updates using COM object (no external modules)

$ReportPath = "C:\Scripts\UpdateReport.txt"

$Header = @"
========================================
WINDOWS UPDATE REPORT - $(Get-Date)
========================================

"@

$Header | Out-File $ReportPath

try {
    $Session = New-Object -ComObject Microsoft.Update.Session
    $Searcher = $Session.CreateUpdateSearcher()
    $Results = $Searcher.Search("IsInstalled=0")

    if ($Results.Updates.Count -eq 0) {
        "System is up to date. No pending updates." | Out-File $ReportPath -Append
    } else {
        "Pending Updates: $($Results.Updates.Count)" | Out-File $ReportPath -Append
        "" | Out-File $ReportPath -Append
        $Results.Updates |
            Select-Object Title, @{N='Severity';E={$_.MsrcSeverity}} |
            Format-Table -AutoSize |
            Out-File $ReportPath -Append
    }
} catch {
    "Error: $($_.Exception.Message)" | Out-File $ReportPath -Append
}

Get-Content $ReportPath
