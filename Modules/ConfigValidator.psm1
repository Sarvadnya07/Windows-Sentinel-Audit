Set-StrictMode -Version Latest

function Invoke-ConfigValidation {
    param([string]$ConfigDir)
    $config = @{}
    
    $rwPath = Join-Path $ConfigDir "RiskWeights.json"
    if (Test-Path $rwPath) { 
        $config.RiskWeights = Get-Content $rwPath -Raw | ConvertFrom-Json 
    } else { 
        Write-Warning "RiskWeights.json missing, using safe defaults."
        $config.RiskWeights = @{
            UnsignedBinary = 25; InvalidSignature = 20; UserWritableLocation = 20; TempExecution = 30; PublicConnection = 10;
            ManyConnections = 15; SystemDirectory = -10; TrustedPublisher = -15; RunningService = 5; StartupPersistence = 15;
            ScheduledTask = 15; ParentMismatch = 10; MissingExecutable = 15
        }
    }
    
    $slPath = Join-Path $ConfigDir "SuspiciousLocations.json"
    if (Test-Path $slPath) { 
        $config.SuspiciousLocations = Get-Content $slPath -Raw | ConvertFrom-Json 
    } else { 
        Write-Warning "SuspiciousLocations.json missing, using empty defaults."
        $config.SuspiciousLocations = [PSCustomObject]@{Locations=@()} 
    }
    
    $tpPath = Join-Path $ConfigDir "TrustedPublishers.json"
    if (Test-Path $tpPath) { 
        $config.TrustedPublishers = Get-Content $tpPath -Raw | ConvertFrom-Json 
    } else { 
        Write-Warning "TrustedPublishers.json missing, using empty defaults."
        $config.TrustedPublishers = [PSCustomObject]@{Publishers=@()} 
    }
    
    return $config
}

Export-ModuleMember -Function Invoke-ConfigValidation
