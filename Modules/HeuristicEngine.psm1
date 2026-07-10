Set-StrictMode -Version Latest

function Test-SuspiciousLocation {
    param(
        [string]$Path,
        $Config
    )
    if([string]::IsNullOrWhiteSpace($Path)){
        return $false
    }
    foreach($Location in $Config.SuspiciousLocations.Locations){
        if($Path -like "*$Location*"){
            return $true
        }
    }
    return $false
}

function Test-TrustedPublisher {
    param(
        [string]$Publisher,
        $Config
    )
    if([string]::IsNullOrWhiteSpace($Publisher)){
        return $false
    }
    foreach($Trusted in $Config.TrustedPublishers.Publishers){
        if($Publisher -like "*$Trusted*"){
            return $true
        }
    }
    return $false
}

Export-ModuleMember -Function *
