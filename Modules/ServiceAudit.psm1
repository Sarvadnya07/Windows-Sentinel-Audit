Set-StrictMode -Version Latest

<#
.SYNOPSIS
Returns service data from the centralized audit cache.
#>
function Invoke-ServiceAudit {
    $Services = (Get-AuditCache).ServiceList
    return $Services
}

Export-ModuleMember -Function Invoke-ServiceAudit
