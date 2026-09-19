Set-StrictMode -Version Latest

<#
.SYNOPSIS
Reads files from common Windows startup folders.
#>
function Get-StartupFolderEntry {
    $Folders = @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    )

    $Results = @()

    foreach ($Folder in $Folders) {
        if (-not (Test-Path -LiteralPath $Folder)) {
            continue
        }

        Get-ChildItem -LiteralPath $Folder -ErrorAction SilentlyContinue |
            ForEach-Object {
                $Results += [PSCustomObject]@{
                    Type = "StartupFolder"
                    Folder = $Folder
                    Name = $_.Name
                    Path = $_.FullName
                }
            }
    }

    return $Results
}

Set-Alias -Name Get-StartupFolderEntries -Value Get-StartupFolderEntry -Scope Script

Export-ModuleMember -Function Get-StartupFolderEntry -Alias Get-StartupFolderEntries
