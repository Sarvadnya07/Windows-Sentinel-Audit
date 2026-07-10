Set-StrictMode -Version Latest

function Invoke-NetworkAudit {
    $Cache = Get-AuditCache
    $Processes = $Cache.ProcessList
    $ProcessLookup = $Cache.ProcessLookup
    $Connections = $Cache.TCPConnections

    $results = @()
    if ($Connections) {
        foreach ($conn in $Connections) {
            $type = if ($conn.RemoteAddress -eq '127.0.0.1' -or $conn.RemoteAddress -eq '::1') { 'Loopback' }
                    elseif ($conn.RemoteAddress -match '^10\.|^172\.(1[6-9]|2[0-9]|3[0-1])\.|^192\.168\.') { 'Private' }
                    else { 'Public' }
            
            $results += @{
                ProcessId = $conn.OwningProcess
                LocalAddress = $conn.LocalAddress
                LocalPort = $conn.LocalPort
                RemoteAddress = $conn.RemoteAddress
                RemotePort = $conn.RemotePort
                State = $conn.State
                Type = $type
            }
        }
    }
    return $results
}
Export-ModuleMember -Function Invoke-NetworkAudit
