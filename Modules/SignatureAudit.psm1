Set-StrictMode -Version Latest

<#
.SYNOPSIS
Audits Authenticode signatures for running process executables.
#>
function Invoke-SignatureAudit {
    $Errors = [System.Collections.ArrayList]::new()
    $Results = @()

    try {
        $Processes = Get-CimInstance -ClassName Win32_Process

        foreach ($Process in $Processes) {
            if ([string]::IsNullOrWhiteSpace($Process.ExecutablePath)) {
                continue
            }

            if (-not (Test-Path -LiteralPath $Process.ExecutablePath)) {
                continue
            }

            try {
                $Signature = Get-AuthenticodeSignature -FilePath $Process.ExecutablePath
                $Signer = $null

                if ($Signature.SignerCertificate) {
                    $Signer = $Signature.SignerCertificate.Subject
                }

                $Results += [PSCustomObject]@{
                    ProcessName = $Process.Name
                    PID = $Process.ProcessId
                    Path = $Process.ExecutablePath
                    SignatureStatus = $Signature.Status
                    IsOSBinary = $Signature.IsOSBinary
                    Signer = $Signer
                }
            }
            catch {
                Write-Verbose (
                    "Signature lookup failed for PID {0}: {1}" -f
                    $Process.ProcessId,
                    $_.Exception.Message
                )
            }
        }
    }
    catch {
        Add-AuditError -Collection $Errors -Message $_.Exception.Message
    }

    return New-AuditResult -Module SignatureAudit -Data $Results -Errors $Errors
}

Export-ModuleMember -Function Invoke-SignatureAudit
