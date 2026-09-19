Set-StrictMode -Version Latest

<#
.SYNOPSIS
Computes summary statistics for an audit process collection.

.PARAMETER Processes
Process records returned by the process audit.
#>
function Get-ProcessStatistic {
    param(
        [Parameter(Mandatory)]
        $Processes
    )

    $Cache = Get-AuditCache

    [PSCustomObject]@{
        TotalProcesses = $Processes.Count
        RunningServices = $Cache.ServiceList.Count
        TCPConnections = $Cache.TCPConnections.Count
        Unsigned = ($Processes | Where-Object { $null -eq $_.Path }).Count
    }
}

Set-Alias -Name Get-ProcessStatistics -Value Get-ProcessStatistic -Scope Script

Export-ModuleMember -Function Get-ProcessStatistic -Alias Get-ProcessStatistics
