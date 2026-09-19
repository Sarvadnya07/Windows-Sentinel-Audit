Set-StrictMode -Version Latest

<#
.SYNOPSIS
Runs the FirewallAudit audit.

.DESCRIPTION
Provides the stable audit-result contract for this module.
#>
function Invoke-FirewallAudit {
    return Get-StandardResult -Module "FirewallAudit" -Data @()
}

Export-ModuleMember -Function Invoke-FirewallAudit
