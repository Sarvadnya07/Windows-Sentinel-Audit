Set-StrictMode -Version Latest
function Invoke-ProcessTree {
    $Processes = (Get-AuditCache).ProcessList
    return $Processes
}
Export-ModuleMember -Function Invoke-ProcessTree
