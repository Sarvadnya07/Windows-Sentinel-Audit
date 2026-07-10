Set-StrictMode -Version Latest

function Invoke-CorrelationEngine {
    $Cache = Get-AuditCache
    $Connections = $Cache.TCPConnections
    $Processes = $Cache.ProcessLookup

    $Output = foreach($Connection in $Connections){
        $Process = $Processes[$Connection.OwningProcess]
        if(-not $Process){
            continue
        }

        [PSCustomObject]@{
            ProcessName = $Process.Name
            PID = $Process.ProcessId
            ParentPID = $Process.ParentProcessId
            Path = $Process.ExecutablePath
            LocalAddress = $Connection.LocalAddress
            LocalPort = $Connection.LocalPort
            RemoteAddress = $Connection.RemoteAddress
            RemotePort = $Connection.RemotePort
            State = $Connection.State
        }
    }
    return $Output
}

Export-ModuleMember -Function Invoke-CorrelationEngine
