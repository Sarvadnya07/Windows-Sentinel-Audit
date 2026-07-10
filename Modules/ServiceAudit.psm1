Set-StrictMode -Version Latest
function Invoke-ServiceAudit {
    $Services = (Get-AuditCache).ServiceList
    return $Services
}
Export-ModuleMember -Function Invoke-ServiceAudit
