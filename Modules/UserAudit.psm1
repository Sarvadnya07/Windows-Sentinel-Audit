Set-StrictMode -Version Latest

<#
.SYNOPSIS
Runs the UserAudit audit.

.DESCRIPTION
Provides the stable audit-result contract for this module.
#>
function Invoke-UserAudit {
    return Get-StandardResult -Module "UserAudit" -Data @()
}

Export-ModuleMember -Function Invoke-UserAudit
