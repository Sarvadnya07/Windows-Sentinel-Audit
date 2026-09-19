Set-StrictMode -Version Latest

<#
.SYNOPSIS
Runs the CertificateAudit audit.

.DESCRIPTION
Provides the stable audit-result contract for this module.
#>
function Invoke-CertificateAudit {
    return Get-StandardResult -Module "CertificateAudit" -Data @()
}

Export-ModuleMember -Function Invoke-CertificateAudit
