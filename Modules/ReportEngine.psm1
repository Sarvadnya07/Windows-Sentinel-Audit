Set-StrictMode -Version Latest

<#
.SYNOPSIS
Constructs the combined AbuserHunter report object.

.DESCRIPTION
Creates an in-memory report representation without modifying the target
system.
#>
function New-AbuserHunterReport {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'This function constructs an in-memory report only.'
    )]
    param(
        [Parameter(Mandatory)]$ProcessAudit,
        [Parameter(Mandatory)]$NetworkAudit,
        [Parameter(Mandatory)]$ServiceAudit,
        [Parameter(Mandatory)]$SignatureAudit,
        [Parameter(Mandatory)]$PersistenceAudit,
        [Parameter(Mandatory)]$RiskResults,
        [Parameter(Mandatory)]$Investigation
    )

    $Summary = [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        UserName = $env:USERNAME
        GeneratedAt = Get-Date
        ProcessCount = @($ProcessAudit.Data).Count
        NetworkCount = @($NetworkAudit.Data).Count
        ServiceCount = @($ServiceAudit.Data).Count
        PersistenceCount = @($PersistenceAudit.Data).Count
        HighRiskCount = @(
            $RiskResults | Where-Object RiskScore -ge 60
        ).Count
    }

    return [PSCustomObject]@{
        Summary = $Summary
        Processes = $ProcessAudit.Data
        Network = $NetworkAudit.Data
        Services = $ServiceAudit.Data
        Signatures = $SignatureAudit.Data
        Persistence = $PersistenceAudit.Data
        Risk = $RiskResults
        Investigation = $Investigation
    }
}

Export-ModuleMember -Function New-AbuserHunterReport
