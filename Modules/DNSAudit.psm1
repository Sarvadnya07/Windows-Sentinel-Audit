Set-StrictMode -Version Latest

<#
.SYNOPSIS
Runs the DNSAudit audit.

.DESCRIPTION
Provides the stable audit-result contract for this module.
#>
function Invoke-DNSAudit {
    return Get-StandardResult -Module "DNSAudit" -Data @()
}

Export-ModuleMember -Function Invoke-DNSAudit
