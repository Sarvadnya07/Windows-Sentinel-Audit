Set-StrictMode -Version Latest

function Get-StartupFolderEntries {
    $Folders = @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    )

    $Results = @()

    foreach($Folder in $Folders){
        if(!(Test-Path $Folder)){
            continue
        }
        Get-ChildItem $Folder -ErrorAction SilentlyContinue | ForEach-Object{
            $Results += [PSCustomObject]@{
                Type="StartupFolder"
                Folder=$Folder
                Name=$_.Name
                Path=$_.FullName
            }
        }
    }
    return $Results
}

Export-ModuleMember -Function *
