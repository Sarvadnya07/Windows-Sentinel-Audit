Set-StrictMode -Version Latest

$script:LogDirectory = $null
$script:LogFile = $null

function Initialize-Logger {

    param(
        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    $script:LogDirectory = Join-Path $OutputPath "Logs"

    if (!(Test-Path $script:LogDirectory)) {
        New-Item -ItemType Directory -Path $script:LogDirectory -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

    $script:LogFile = Join-Path $script:LogDirectory "Audit_$timestamp.log"
}

function Write-AuditLog {

    param(

        [ValidateSet("INFO","WARN","ERROR","DEBUG")]
        [string]$Level,

        [string]$Module,

        [string]$Message
    )

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $line = "[{0}] [{1}] [{2}] {3}" -f $time,$Level,$Module,$Message

    Write-Host $line

    switch($Level){

        "INFO" { Write-Host $line -ForegroundColor Cyan }

        "WARN" { Write-Host $line -ForegroundColor Yellow }

        "ERROR"{ Write-Host $line -ForegroundColor Red }

        "DEBUG"{ Write-Host $line -ForegroundColor Gray }

    }

}

Export-ModuleMember -Function *
