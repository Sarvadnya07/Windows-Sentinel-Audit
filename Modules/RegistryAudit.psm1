Set-StrictMode -Version Latest

function Get-RegistryRunEntries {
    $Locations = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    )

    $Results = @()

    foreach($Location in $Locations){
        if(!(Test-Path $Location)){
            continue
        }
        try{
            $Item = Get-ItemProperty -Path $Location
            foreach($Property in $Item.PSObject.Properties){
                if($Property.Name -like "PS*"){
                    continue
                }
                $Results += [PSCustomObject]@{
                    Type="Registry"
                    Location=$Location
                    Name=$Property.Name
                    Command=$Property.Value
                }
            }
        }
        catch{
        }
    }
    return $Results
}

Export-ModuleMember -Function *
