Set-StrictMode -Version Latest

function Get-ProcessStatistics {
    param($Processes)
    [PSCustomObject]@{
        TotalProcesses = $Processes.Count
        RunningServices = (Get-AuditCache).ServiceList.Count
        TCPConnections = (Get-AuditCache).TCPConnections.Count
        Unsigned = ($Processes | Where-Object Company -eq $null).Count
    }
}
Export-ModuleMember -Function *
