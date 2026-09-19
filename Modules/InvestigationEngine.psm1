Set-StrictMode -Version Latest

<#
.SYNOPSIS
Correlates process, network, service, persistence, and risk findings.
#>
function Invoke-InvestigationEngine {
    param(
        [Parameter(Mandatory)]$Processes,
        [Parameter(Mandatory)]$Network,
        [Parameter(Mandatory)]$Services,
        [Parameter(Mandatory)]$Persistence,
        [Parameter(Mandatory)]$Risk
    )

    $Results = foreach ($Process in $Processes) {
        $Connections = @(
            $Network | Where-Object ProcessId -eq $Process.PID
        )
        $Service = $Services |
            Where-Object ProcessId -eq $Process.PID |
            Select-Object -First 1
        $RiskEntry = $Risk |
            Where-Object PID -eq $Process.PID |
            Select-Object -First 1

        $PersistenceMatches = @()

        if ($Process.Path) {
            foreach ($Entry in $Persistence) {
                if ($Entry.PSObject.Properties.Name -contains "Command") {
                    if ($Entry.Command -like "*$($Process.Path)*") {
                        $PersistenceMatches += $Entry
                    }
                }

                if ($Entry.PSObject.Properties.Name -contains "Path") {
                    if ($Entry.Path -eq $Process.Path) {
                        $PersistenceMatches += $Entry
                    }
                }
            }
        }

        [PSCustomObject]@{
            ProcessName = $Process.ProcessName
            PID = $Process.PID
            ParentPID = $Process.ParentPID
            Path = $Process.Path
            ConnectionCount = $Connections.Count
            Service = if ($Service) { $Service.Name } else { $null }
            PersistenceCount = $PersistenceMatches.Count
            RiskScore = if ($RiskEntry) { $RiskEntry.RiskScore } else { 0 }
            RiskLevel = if ($RiskEntry) {
                $RiskEntry.RiskLevel
            }
            else {
                "Informational"
            }
            Reasons = if ($RiskEntry) { $RiskEntry.Reasons } else { "" }
        }
    }

    return $Results
}

Export-ModuleMember -Function Invoke-InvestigationEngine
