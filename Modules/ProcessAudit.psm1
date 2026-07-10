Set-StrictMode -Version Latest

function Invoke-ProcessAudit {
    $Processes = (Get-AuditCache).ProcessList
    
    $results = @()
    if ($Processes) {
        foreach ($p in $Processes) {
            $results += @{
                ProcessName = $p.Name
                PID = $p.ProcessId
                ParentPID = $p.ParentProcessId
                Path = $p.ExecutablePath
                CommandLine = $p.CommandLine
                CreationDate = $p.CreationDate
            }
        }
    }
    return $results
}
Export-ModuleMember -Function Invoke-ProcessAudit
