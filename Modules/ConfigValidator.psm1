Set-StrictMode -Version Latest

<#
.SYNOPSIS
Loads and validates the audit configuration files.

.PARAMETER ConfigDir
Directory containing the JSON configuration files.
#>
function Invoke-ConfigValidation {
    param(
        [Parameter(Mandatory)]
        [string]$ConfigDir
    )

    $Config = @{}

    $RiskWeightsPath = Join-Path $ConfigDir "RiskWeights.json"

    if (Test-Path -LiteralPath $RiskWeightsPath) {
        $Config.RiskWeights = Get-Content -LiteralPath $RiskWeightsPath -Raw | ConvertFrom-Json
    }
    else {
        Write-Warning "RiskWeights.json missing, using safe defaults."
        $Config.RiskWeights = @{
            UnsignedBinary = 25
            InvalidSignature = 20
            UserWritableLocation = 20
            TempExecution = 30
            PublicConnection = 10
            ManyConnections = 15
            SystemDirectory = -10
            TrustedPublisher = -15
            RunningService = 5
            StartupPersistence = 15
            ScheduledTask = 15
            ParentMismatch = 10
            MissingExecutable = 15
        }
    }

    $SuspiciousLocationsPath = Join-Path $ConfigDir "SuspiciousLocations.json"

    if (Test-Path -LiteralPath $SuspiciousLocationsPath) {
        $Config.SuspiciousLocations = Get-Content -LiteralPath $SuspiciousLocationsPath -Raw | ConvertFrom-Json
    }
    else {
        Write-Warning "SuspiciousLocations.json missing, using empty defaults."
        $Config.SuspiciousLocations = [PSCustomObject]@{ Locations = @() }
    }

    $TrustedPublishersPath = Join-Path $ConfigDir "TrustedPublishers.json"

    if (Test-Path -LiteralPath $TrustedPublishersPath) {
        $Config.TrustedPublishers = Get-Content -LiteralPath $TrustedPublishersPath -Raw | ConvertFrom-Json
    }
    else {
        Write-Warning "TrustedPublishers.json missing, using empty defaults."
        $Config.TrustedPublishers = [PSCustomObject]@{ Publishers = @() }
    }

    return $Config
}

Export-ModuleMember -Function Invoke-ConfigValidation
