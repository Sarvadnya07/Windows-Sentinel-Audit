<#
.SYNOPSIS
Runs the complete SystemWide-AbuserHunter forensic audit pipeline.

.DESCRIPTION
Executes read-only telemetry collection, heuristic risk scoring,
investigation, and report generation.
#>
function Invoke-SystemWideAbuserHunter {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost',
        '',
        Justification = 'The orchestrator intentionally provides a colorized interactive CLI.'
    )]
    [CmdletBinding()]
    param()

    $ScriptPath = $MyInvocation.MyCommand.Path
    $BasePath = Split-Path $ScriptPath

    Write-Host -Object "========================================" -ForegroundColor Cyan
    Write-Host -Object " SystemWide-AbuserHunter" -ForegroundColor Cyan
    Write-Host -Object "========================================" -ForegroundColor Cyan

    . (Join-Path $BasePath "Core\Bootstrap.ps1") -BasePath $BasePath

    Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Initializing Cache..." -PercentComplete 10
    $SwTotal = [Diagnostics.Stopwatch]::StartNew()
    $Sw = [Diagnostics.Stopwatch]::StartNew()

    Initialize-AuditCache
    Update-AuditCache
    $Sw.Stop()

    Write-Host -Object ("✓ Cache Initialization ....... {0} sec" -f $Sw.Elapsed.TotalSeconds.ToString('0.00')) -ForegroundColor Green

    $Config = Invoke-ConfigValidation -ConfigDir (Join-Path $BasePath "Config")

    Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Process Audit..." -PercentComplete 20
    $Sw.Restart()

    try {
        $ProcessAudit = Invoke-ProcessAudit
    }
    catch {
        Write-Warning "Process Audit Failed: $_"
        $ProcessAudit = @()
    }

    $Sw.Stop()
    Write-Host -Object ("✓ Process Audit .............. {0} sec" -f $Sw.Elapsed.TotalSeconds.ToString('0.00')) -ForegroundColor Green

    Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Network Audit..." -PercentComplete 40
    $Sw.Restart()

    try {
        $NetworkAudit = Invoke-NetworkAudit
    }
    catch {
        Write-Warning "Network Audit Failed: $_"
        $NetworkAudit = @()
    }

    $Sw.Stop()
    Write-Host -Object ("✓ Network Audit .............. {0} sec" -f $Sw.Elapsed.TotalSeconds.ToString('0.00')) -ForegroundColor Green

    Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Service Audit..." -PercentComplete 50
    $Sw.Restart()

    try {
        $ServiceAudit = Invoke-ServiceAudit
    }
    catch {
        Write-Warning "Service Audit Failed: $_"
        $ServiceAudit = @()
    }

    $Sw.Stop()
    Write-Host -Object ("✓ Service Audit .............. {0} sec" -f $Sw.Elapsed.TotalSeconds.ToString('0.00')) -ForegroundColor Green

    Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Signature Audit..." -PercentComplete 60
    $Sw.Restart()

    try {
        $SignatureAudit = Invoke-SignatureAudit
    }
    catch {
        Write-Warning "Signature Audit Failed: $_"
        $SignatureAudit = Get-StandardResult -Module SignatureAudit -Data @() -Errors @($_.Exception.Message)
    }

    $Sw.Stop()
    Write-Host -Object ("✓ Signature Audit ............ {0} sec" -f $Sw.Elapsed.TotalSeconds.ToString('0.00')) -ForegroundColor Green

    Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Risk Engine..." -PercentComplete 70
    $Sw.Restart()

    try {
        $Risk = Invoke-RiskEngine -Processes $ProcessAudit -Signatures $SignatureAudit.Data -Connections $NetworkAudit -Config $Config
    }
    catch {
        Write-Warning "Risk Engine Failed: $_"
        $Risk = @()
    }

    $Sw.Stop()
    Write-Host -Object ("✓ Risk Engine ................ {0} sec" -f $Sw.Elapsed.TotalSeconds.ToString('0.00')) -ForegroundColor Green

    Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Persistence Audit..." -PercentComplete 80
    $Sw.Restart()

    try {
        $Persistence = Invoke-PersistenceAudit
    }
    catch {
        Write-Warning "Persistence Audit Failed: $_"
        $Persistence = [PSCustomObject]@{ Data = @() }
    }

    $Sw.Stop()
    Write-Host -Object ("✓ Persistence Audit .......... {0} sec" -f $Sw.Elapsed.TotalSeconds.ToString('0.00')) -ForegroundColor Green

    Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Investigation Engine..." -PercentComplete 90
    $Sw.Restart()

    try {
        $Investigation = Invoke-InvestigationEngine -Processes $ProcessAudit -Network $NetworkAudit -Services $ServiceAudit -Persistence $Persistence.Data -Risk $Risk
    }
    catch {
        Write-Warning "Investigation Engine Failed: $_"
        $Investigation = @()
    }

    $Sw.Stop()
    Write-Host -Object ("✓ Investigation Engine ....... {0} sec" -f $Sw.Elapsed.TotalSeconds.ToString('0.00')) -ForegroundColor Green

    Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Generating Reports..." -PercentComplete 95

    $Report = New-AbuserHunterReport -ProcessAudit @{ Data = $ProcessAudit } -NetworkAudit @{ Data = $NetworkAudit } -ServiceAudit @{ Data = $ServiceAudit } -SignatureAudit $SignatureAudit -PersistenceAudit $Persistence -RiskResults $Risk -Investigation $Investigation

    $RunId = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $ReportsDir = Join-Path $BasePath "Reports\$RunId"
    New-Item -ItemType Directory -Path $ReportsDir -Force | Out-Null

    [void](Export-AbuserHunterJson -Report $Report -OutputFolder $ReportsDir)
    [void](Export-AbuserHunterCsv -Report $Report -OutputFolder $ReportsDir)
    [void](Export-AbuserHunterHtml -Report $Report -OutputFolder $ReportsDir)

    Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Completed" -PercentComplete 100
    $SwTotal.Stop()

    Write-Host -Object ""
    Write-Host -Object ("Total Runtime: {0} seconds" -f $SwTotal.Elapsed.TotalSeconds.ToString('0.00')) -ForegroundColor Cyan

    $Stats = Get-ProcessStatistic -Processes $ProcessAudit
    $HighRisk = @($Risk | Where-Object { $_.RiskLevel -eq 'Critical' -or $_.RiskLevel -eq 'High' }).Count
    $MediumRisk = @($Risk | Where-Object RiskLevel -eq 'Medium').Count
    $LowRisk = @($Risk | Where-Object RiskLevel -eq 'Low').Count

    Write-Host -Object ""
    Write-Host -Object "========================================" -ForegroundColor Cyan
    Write-Host -Object " SYSTEM OVERVIEW" -ForegroundColor Cyan
    Write-Host -Object "========================================" -ForegroundColor Cyan
    Write-Host -Object "Processes          : $($Stats.TotalProcesses)"
    Write-Host -Object "Services           : $($Stats.RunningServices)"
    Write-Host -Object "TCP Connections    : $($Stats.TCPConnections)"
    Write-Host -Object "Persistence Items  : $($Persistence.Data.Count)"
    Write-Host -Object ""
    Write-Host -Object "High Risk          : $HighRisk" -ForegroundColor Red
    Write-Host -Object "Medium Risk        : $MediumRisk" -ForegroundColor Yellow
    Write-Host -Object "Low Risk           : $LowRisk" -ForegroundColor Green
    Write-Host -Object ""
    Write-Host -Object "Report Folder:"
    Write-Host -Object $ReportsDir -ForegroundColor Cyan
    Write-Host -Object ""
    Write-Host -Object "Investigation Tips:" -ForegroundColor Yellow
    Write-Host -Object "1. Review high-risk items first."
    Write-Host -Object "2. Check unsigned executables running from user-writable locations."
    Write-Host -Object "3. Confirm whether unusual startup entries are expected software."
    Write-Host -Object "4. Investigate unexpected parent-child process relationships."
    Write-Host -Object "5. Verify services with non-standard executable paths."
    Write-Host -Object "6. Remember that heuristic findings are not proof of compromise." -ForegroundColor Cyan
}

Invoke-SystemWideAbuserHunter
