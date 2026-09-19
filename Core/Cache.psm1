Set-StrictMode -Version Latest

$script:AuditCache = @{}

<#
.SYNOPSIS
Initializes the in-memory audit cache.
#>
function Initialize-AuditCache {
    $script:AuditCache = @{
        Processes = @{}
        Services = @{}
        TCPConnections = @()
        ProcessLookup = @{}
        ServiceLookup = @{}
        ProcessList = @()
        ServiceList = @()
        Initialized = $false
    }
}

<#
.SYNOPSIS
Refreshes the in-memory audit cache from native Windows telemetry.

.DESCRIPTION
Reads process, service, and TCP connection data without modifying the
target system.
#>
function Update-AuditCache {
    $Processes = Get-CimInstance -ClassName Win32_Process
    $Services = Get-CimInstance -ClassName Win32_Service

    $ProcessLookup = @{}
    foreach ($Process in $Processes) {
        $ProcessLookup[$Process.ProcessId] = $Process
    }

    $ServiceLookup = @{}
    foreach ($Service in $Services) {
        $ServiceLookup[$Service.Name] = $Service
    }

    $script:AuditCache.ProcessList = $Processes
    $script:AuditCache.ServiceList = $Services
    $script:AuditCache.ProcessLookup = $ProcessLookup
    $script:AuditCache.ServiceLookup = $ServiceLookup

    try {
        $script:AuditCache.TCPConnections =
            @(Get-NetTCPConnection -ErrorAction Stop)
    }
    catch {
        $script:AuditCache.TCPConnections = @()
        Write-Verbose "TCP connection enumeration was unavailable."
    }

    $script:AuditCache.Initialized = $true
}

<#
.SYNOPSIS
Returns the current audit cache, refreshing it when necessary.
#>
function Get-AuditCache {
    if (-not $script:AuditCache.Initialized) {
        Update-AuditCache
    }

    return $script:AuditCache
}

Set-Alias -Name Build-AuditCache -Value Update-AuditCache -Scope Script

Export-ModuleMember -Function Initialize-AuditCache, Update-AuditCache, Get-AuditCache -Alias Build-AuditCache
