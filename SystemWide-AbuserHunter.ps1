param()
$scriptPath = $MyInvocation.MyCommand.Path
$basePath = Split-Path $scriptPath

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " SystemWide-AbuserHunter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

. (Join-Path $basePath "Core\Bootstrap.ps1") -BasePath $basePath

Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Initializing Cache..." -PercentComplete 10
$swTotal = [Diagnostics.Stopwatch]::StartNew()

$sw = [Diagnostics.Stopwatch]::StartNew()
Initialize-AuditCache
Build-AuditCache
$sw.Stop()
Write-Host "✓ Cache Initialization ....... $($sw.Elapsed.TotalSeconds.ToString('0.00')) sec" -ForegroundColor Green

$config = Invoke-ConfigValidation -ConfigDir (Join-Path $basePath "Config")

Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Process Audit..." -PercentComplete 20
$sw.Restart()
try { $procAudit = Invoke-ProcessAudit } catch { Write-Warning "Process Audit Failed: $_"; $procAudit = @() }
$sw.Stop()
Write-Host "✓ Process Audit .............. $($sw.Elapsed.TotalSeconds.ToString('0.00')) sec" -ForegroundColor Green

Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Network Audit..." -PercentComplete 40
$sw.Restart()
try { $netAudit = Invoke-NetworkAudit } catch { Write-Warning "Network Audit Failed"; $netAudit = @() }
$sw.Stop()
Write-Host "✓ Network Audit .............. $($sw.Elapsed.TotalSeconds.ToString('0.00')) sec" -ForegroundColor Green

Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Service Audit..." -PercentComplete 50
$sw.Restart()
try { $svcAudit = Invoke-ServiceAudit } catch { Write-Warning "Service Audit Failed"; $svcAudit = @() }
$sw.Stop()
Write-Host "✓ Service Audit .............. $($sw.Elapsed.TotalSeconds.ToString('0.00')) sec" -ForegroundColor Green

$sigAudit = @()

Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Correlation Engine..." -PercentComplete 60
$sw.Restart()
try { $Correlation = Invoke-CorrelationEngine } catch { Write-Warning "Correlation Failed"; $Correlation = @() }
$sw.Stop()
Write-Host "✓ Correlation Engine ......... $($sw.Elapsed.TotalSeconds.ToString('0.00')) sec" -ForegroundColor Green

Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Risk Engine..." -PercentComplete 70
$sw.Restart()
try { $risk = Invoke-RiskEngine -Processes $procAudit -Signatures $sigAudit -Connections $netAudit -Config $config } catch { Write-Warning "Risk Engine Failed: $_"; $risk = @() }
$sw.Stop()
Write-Host "✓ Risk Engine ................ $($sw.Elapsed.TotalSeconds.ToString('0.00')) sec" -ForegroundColor Green

Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Persistence Audit..." -PercentComplete 80
$sw.Restart()
try { $Persistence = Invoke-PersistenceAudit } catch { Write-Warning "Persistence Audit Failed"; $Persistence = [PSCustomObject]@{Data=@()} }
$sw.Stop()
Write-Host "✓ Persistence Audit .......... $($sw.Elapsed.TotalSeconds.ToString('0.00')) sec" -ForegroundColor Green

Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Running Investigation Engine..." -PercentComplete 90
$sw.Restart()
try { $Investigation = Invoke-InvestigationEngine -Processes $procAudit -Network $netAudit -Services $svcAudit -Persistence $Persistence.Data -Risk $risk } catch { Write-Warning "Investigation Engine Failed: $_"; $Investigation = @() }
$sw.Stop()
Write-Host "✓ Investigation Engine ....... $($sw.Elapsed.TotalSeconds.ToString('0.00')) sec" -ForegroundColor Green

Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Generating Reports..." -PercentComplete 95

$Report = New-AbuserHunterReport `
    -ProcessAudit @{Data=$procAudit} `
    -NetworkAudit @{Data=$netAudit} `
    -ServiceAudit @{Data=$svcAudit} `
    -SignatureAudit @{Data=$sigAudit} `
    -PersistenceAudit $Persistence `
    -RiskResults $risk `
    -Investigation $Investigation

$runId = Get-Date -Format "yyyy-MM-dd_HHmmss"
$reportsDir = Join-Path $basePath "Reports\$runId"
New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null

$json = Export-AbuserHunterJson -Report $Report -OutputFolder $reportsDir
$csv = Export-AbuserHunterCsv -Report $Report -OutputFolder $reportsDir
$html = Export-AbuserHunterHtml -Report $Report -OutputFolder $reportsDir

Write-Progress -Activity "SystemWide-AbuserHunter" -Status "Completed" -PercentComplete 100
$swTotal.Stop()

Write-Host ""
Write-Host "Total Runtime: $($swTotal.Elapsed.TotalSeconds.ToString('0.00')) seconds" -ForegroundColor Cyan

$Stats = Get-ProcessStatistics $procAudit
$highRisk = ($risk | Where-Object { $_.RiskLevel -eq 'Critical' -or $_.RiskLevel -eq 'High' }).Count
if ($null -eq $highRisk) { $highRisk = 0 }
$medRisk = ($risk | Where-Object RiskLevel -eq 'Medium').Count
if ($null -eq $medRisk) { $medRisk = 0 }
$lowRisk = ($risk | Where-Object RiskLevel -eq 'Low').Count
if ($null -eq $lowRisk) { $lowRisk = 0 }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " SYSTEM OVERVIEW" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Processes          : $($Stats.TotalProcesses)"
Write-Host "Services           : $($Stats.RunningServices)"
Write-Host "TCP Connections    : $($Stats.TCPConnections)"
Write-Host "Persistence Items  : $($Persistence.Data.Count)"
Write-Host ""
Write-Host "High Risk          : $highRisk" -ForegroundColor Red
Write-Host "Medium Risk        : $medRisk" -ForegroundColor Yellow
Write-Host "Low Risk           : $lowRisk" -ForegroundColor Green
Write-Host ""
Write-Host "Report Folder:"
Write-Host $reportsDir -ForegroundColor Cyan

Write-Host ""
Write-Host "Investigation Tips:" -ForegroundColor Yellow
Write-Host "1. Review high-risk items first."
Write-Host "2. Check unsigned executables running from user-writable locations."
Write-Host "3. Confirm whether unusual startup entries are expected software."
Write-Host "4. Investigate unexpected parent-child process relationships."
Write-Host "5. Verify services with non-standard executable paths."
Write-Host "6. Remember that heuristic findings are not proof of compromise." -ForegroundColor Cyan
