Set-StrictMode -Version Latest

<#
.SYNOPSIS
Runs the EventLogAudit audit.

.DESCRIPTION
Provides the stable audit-result contract for this module.
#>
function Invoke-EventLogAudit {
    return Get-StandardResult -Module "EventLogAudit" -Data @()
}

Export-ModuleMember -Function Invoke-EventLogAudit
