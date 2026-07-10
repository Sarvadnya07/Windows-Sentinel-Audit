Set-StrictMode -Version Latest

function New-AbuserHunterReport {
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
        UserName     = $env:USERNAME
        GeneratedAt  = Get-Date
        ProcessCount = $ProcessAudit.Data.Count
        NetworkCount = $NetworkAudit.Data.Count
        ServiceCount = $ServiceAudit.Data.Count
        PersistenceCount = $PersistenceAudit.Data.Count
        HighRiskCount = ($RiskResults | Where-Object RiskScore -ge 60).Count
    }

    return [PSCustomObject]@{
        Summary      = $Summary
        Processes    = $ProcessAudit.Data
        Network      = $NetworkAudit.Data
        Services     = $ServiceAudit.Data
        Signatures   = $SignatureAudit.Data
        Persistence  = $PersistenceAudit.Data
        Risk         = $RiskResults
        Investigation = $Investigation
    }
}

Export-ModuleMember -Function New-AbuserHunterReport
