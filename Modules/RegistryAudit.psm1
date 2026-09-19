Set-StrictMode -Version Latest

<#
.SYNOPSIS
Reads common Windows Registry Run and RunOnce persistence locations.
#>
function Get-RegistryRunEntry {
    $Locations = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    )

    $Results = @()

    foreach ($Location in $Locations) {
        if (-not (Test-Path -LiteralPath $Location)) {
            continue
        }

        try {
            $Item = Get-ItemProperty -Path $Location

            foreach ($Property in $Item.PSObject.Properties) {
                if ($Property.Name -like "PS*") {
                    continue
                }

                $Results += [PSCustomObject]@{
                    Type = "Registry"
                    Location = $Location
                    Name = $Property.Name
                    Command = $Property.Value
                }
            }
        }
        catch {
            Write-Verbose (
                "Registry persistence lookup failed for {0}: {1}" -f
                $Location,
                $_.Exception.Message
            )
        }
    }

    return $Results
}

Set-Alias -Name Get-RegistryRunEntries -Value Get-RegistryRunEntry -Scope Script

Export-ModuleMember -Function Get-RegistryRunEntry -Alias Get-RegistryRunEntries
