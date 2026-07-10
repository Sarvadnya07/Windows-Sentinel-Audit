Set-StrictMode -Version Latest

$script:AuditCache = @{}

function Initialize-AuditCache {
    $script:AuditCache = @{
        Processes      = @{}
        Services       = @{}
        TCPConnections = @()
        ProcessLookup  = @{}
        ServiceLookup  = @{}
        ProcessList    = @()
        ServiceList    = @()
        Initialized    = $false
    }
}

function Build-AuditCache {
    $Processes = Get-CimInstance Win32_Process
    $Services  = Get-CimInstance Win32_Service

    $ProcessLookup = @{}
    foreach($P in $Processes){
        $ProcessLookup[$P.ProcessId] = $P
    }

    $ServiceLookup = @{}
    foreach($S in $Services){
        $ServiceLookup[$S.Name] = $S
    }

    $script:AuditCache.ProcessList = $Processes
    $script:AuditCache.ServiceList = $Services
    $script:AuditCache.ProcessLookup = $ProcessLookup
    $script:AuditCache.ServiceLookup = $ServiceLookup

    try{
        $script:AuditCache.TCPConnections = Get-NetTCPConnection -ErrorAction Stop
    }
    catch{
        $script:AuditCache.TCPConnections = @()
    }

    $script:AuditCache.Initialized = $true
}

function Get-AuditCache {
    if(-not $script:AuditCache.Initialized){
        Build-AuditCache
    }
    return $script:AuditCache
}

Export-ModuleMember -Function *