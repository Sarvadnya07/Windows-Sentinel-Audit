Set-StrictMode -Version Latest

<#
.SYNOPSIS
Returns network connections from the centralized audit cache.
#>
function Invoke-NetworkAudit {
    $Cache = Get-AuditCache
    $Connections = $Cache.TCPConnections
    $Results = @()

    if ($Connections) {
        foreach ($Connection in $Connections) {
            $Type = if (
                $Connection.RemoteAddress -eq '127.0.0.1' -or
                $Connection.RemoteAddress -eq '::1'
            ) {
                'Loopback'
            }
            elseif (
                $Connection.RemoteAddress -match
                '^10\.|^172\.(1[6-9]|2[0-9]|3[0-1])\.|^192\.168\.'
            ) {
                'Private'
            }
            else {
                'Public'
            }

            $Results += @{
                ProcessId = $Connection.OwningProcess
                LocalAddress = $Connection.LocalAddress
                LocalPort = $Connection.LocalPort
                RemoteAddress = $Connection.RemoteAddress
                RemotePort = $Connection.RemotePort
                State = $Connection.State
                Type = $Type
            }
        }
    }

    return $Results
}

Export-ModuleMember -Function Invoke-NetworkAudit
