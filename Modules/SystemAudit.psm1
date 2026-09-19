Set-StrictMode -Version Latest

<#
.SYNOPSIS
Runs the SystemAudit audit.

.DESCRIPTION
Provides the stable audit-result contract for this module.
#>
function Invoke-SystemAudit {
    return Get-StandardResult -Module "SystemAudit" -Data @()
}

Export-ModuleMember -Function Invoke-SystemAudit
