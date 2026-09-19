Set-StrictMode -Version Latest

<#
.SYNOPSIS
Returns the process list used for process-tree analysis.
#>
function Invoke-ProcessTree {
    $Processes = (Get-AuditCache).ProcessList
    return $Processes
}

Export-ModuleMember -Function Invoke-ProcessTree
