Set-StrictMode -Version Latest

<#
.SYNOPSIS
Runs the DriverAudit audit.

.DESCRIPTION
Provides the stable audit-result contract for this module.
#>
function Invoke-DriverAudit {
    return Get-StandardResult -Module "DriverAudit" -Data @()
}

Export-ModuleMember -Function Invoke-DriverAudit
