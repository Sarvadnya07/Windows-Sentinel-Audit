Set-StrictMode -Version Latest

<#
.SYNOPSIS
Enumerates running processes from the centralized audit cache.
#>
function Invoke-ProcessAudit {
    $Processes = (Get-AuditCache).ProcessList
    $Results = @()

    if ($Processes) {
        foreach ($Process in $Processes) {
            $Results += @{
                ProcessName = $Process.Name
                PID = $Process.ProcessId
                ParentPID = $Process.ParentProcessId
                Path = $Process.ExecutablePath
                CommandLine = $Process.CommandLine
                CreationDate = $Process.CreationDate
            }
        }
    }

    return $Results
}

Export-ModuleMember -Function Invoke-ProcessAudit
