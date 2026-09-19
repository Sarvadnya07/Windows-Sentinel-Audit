Set-StrictMode -Version Latest

<#
.SYNOPSIS
Runs the FileAudit audit.

.DESCRIPTION
Provides the stable audit-result contract for this module.
#>
function Invoke-FileAudit {
    return Get-StandardResult -Module "FileAudit" -Data @()
}

Export-ModuleMember -Function Invoke-FileAudit
