Set-StrictMode -Version Latest

$script:LogDirectory = $null
$script:LogFile = $null

<#
.SYNOPSIS
Initializes the audit logger output directory.

.PARAMETER OutputPath
Root path where audit logs are stored.
#>
function Initialize-Logger {
    param(
        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    $script:LogDirectory = Join-Path $OutputPath "Logs"

    if (-not (Test-Path -LiteralPath $script:LogDirectory)) {
        New-Item -ItemType Directory -Path $script:LogDirectory -Force |
            Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $script:LogFile = Join-Path $script:LogDirectory "Audit_$timestamp.log"
}

<#
.SYNOPSIS
Writes a colorized message to the interactive audit console.

.PARAMETER Level
Severity level of the message.

.PARAMETER Module
Name of the originating module.

.PARAMETER Message
Message content to display.
#>
function Write-AuditLog {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost',
        '',
        Scope = 'Function',
        Target = '*',
        Justification = 'This function is the dedicated interactive console logger.'
    )]
    param(
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level,

        [string]$Module,

        [string]$Message
    )

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[{0}] [{1}] [{2}] {3}" -f $time, $Level, $Module, $Message

    switch ($Level) {
        "INFO" {
            Write-Host -Object $line -ForegroundColor Cyan
        }
        "WARN" {
            Write-Host -Object $line -ForegroundColor Yellow
        }
        "ERROR" {
            Write-Host -Object $line -ForegroundColor Red
        }
        "DEBUG" {
            Write-Host -Object $line -ForegroundColor Gray
        }
    }
}

Export-ModuleMember -Function *
