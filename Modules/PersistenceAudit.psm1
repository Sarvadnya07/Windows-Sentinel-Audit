Set-StrictMode -Version Latest

function Invoke-PersistenceAudit {
    $Output = @()
    $Output += Get-RegistryRunEntries
    $Output += Get-StartupFolderEntries
    $Output += Get-ScheduledTaskEntries

    return [PSCustomObject]@{
        Module = "Persistence"
        Data = $Output
    }
}

Export-ModuleMember -Function *
