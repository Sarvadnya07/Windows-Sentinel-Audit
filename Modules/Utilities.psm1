Set-StrictMode -Version Latest

function Test-IsAdministrator {

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)

    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Convert-FileSize {

    param(
        [Int64]$Bytes
    )

    switch ($Bytes) {

        {$_ -ge 1TB} { return "{0:N2} TB" -f ($Bytes/1TB) }

        {$_ -ge 1GB} { return "{0:N2} GB" -f ($Bytes/1GB) }

        {$_ -ge 1MB} { return "{0:N2} MB" -f ($Bytes/1MB) }

        {$_ -ge 1KB} { return "{0:N2} KB" -f ($Bytes/1KB) }

        default { return "$Bytes B" }

    }

}

function Test-PrivateIP {

    param([string]$IPAddress)

    if ($IPAddress -match '^10\.') { return $true }

    if ($IPAddress -match '^192\.168\.') { return $true }

    if ($IPAddress -match '^172\.(1[6-9]|2[0-9]|3[0-1])\.') { return $true }

    if ($IPAddress -eq "127.0.0.1") { return $true }

    return $false

}

Export-ModuleMember -Function *