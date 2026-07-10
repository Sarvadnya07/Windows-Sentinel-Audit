Set-StrictMode -Version Latest

function Invoke-SignatureAudit {

    $Errors = [System.Collections.ArrayList]::new()
    $Results = @()

    try {

        $Processes = Get-CimInstance Win32_Process

        foreach($Process in $Processes){

            if([string]::IsNullOrWhiteSpace($Process.ExecutablePath)){
                continue
            }

            if(!(Test-Path $Process.ExecutablePath)){
                continue
            }

            try{

                $Signature = Get-AuthenticodeSignature -FilePath $Process.ExecutablePath

                $Signer = $null

                if($Signature.SignerCertificate){
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
            catch{

            }

        }

    }
    catch{

        Add-AuditError -Collection $Errors -Message $_.Exception.Message

    }

    New-AuditResult `
        -Module SignatureAudit `
        -Data $Results `
        -Errors $Errors

}

Export-ModuleMember -Function Invoke-SignatureAudit

Write-Host ""
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "SIGNATURE AUDIT" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

$sigAudit.Data |
Sort-Object ProcessName |
Select-Object ProcessName,
              PID,
              SignatureStatus,
              IsOSBinary,
              Signer |
Format-Table -AutoSize

Write-Host ""
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "RUNNING SERVICES" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

$svcAudit.Data |
Where-Object Running |
Sort-Object Name |
Select-Object Name,
              StartMode,
              ProcessId,
              State,
              Path |
Format-Table -AutoSize