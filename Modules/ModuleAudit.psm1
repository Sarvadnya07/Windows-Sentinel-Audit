Set-StrictMode -Version Latest

<#
.SYNOPSIS
Runs the ModuleAudit audit.

.DESCRIPTION
Provides the stable audit-result contract for this module.
#>
function Invoke-ModuleAudit {
    return Get-StandardResult -Module "ModuleAudit" -Data @()
}

Export-ModuleMember -Function Invoke-ModuleAudit
