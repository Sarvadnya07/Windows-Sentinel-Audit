Set-StrictMode -Version Latest

<#
.SYNOPSIS
Maps a numeric risk score to a risk level.

.PARAMETER Score
Numeric risk score.
#>
function Get-RiskLevel {
    param(
        [int]$Score
    )

    switch ($Score) {
        { $_ -lt 20 } { "Informational"; break }
        { $_ -lt 40 } { "Low"; break }
        { $_ -lt 60 } { "Medium"; break }
        { $_ -lt 80 } { "High"; break }
        default { "Critical" }
    }
}

<#
.SYNOPSIS
Calculates heuristic risk scores for process findings.
#>
function Invoke-RiskEngine {
    param(
        [Parameter(Mandatory)]$Processes,
        [Parameter(Mandatory)]$Signatures,
        [Parameter(Mandatory)]$Connections,
        [Parameter(Mandatory)]$Config
    )

    $Weights = $Config.RiskWeights
    $SignatureLookup = @{}

    foreach ($Signature in $Signatures) {
        $SignatureLookup[$Signature.PID] = $Signature
    }

    $ConnectionCounts = @{}

    foreach ($Connection in $Connections) {
        if (-not $ConnectionCounts.ContainsKey($Connection.ProcessId)) {
            $ConnectionCounts[$Connection.ProcessId] = 0
        }

        $ConnectionCounts[$Connection.ProcessId]++
    }

    $Results = foreach ($Process in $Processes) {
        $Score = 0
        $Reasons = New-Object System.Collections.Generic.List[string]
        $Signature = $SignatureLookup[$Process.PID]

        if ($Signature) {
            if ($Signature.SignatureStatus -ne "Valid") {
                $Score += $Weights.InvalidSignature
                $Reasons.Add("Invalid digital signature")
            }

            if (Test-TrustedPublisher -Publisher $Signature.Signer -Config $Config) {
                $Score += $Weights.TrustedPublisher
                $Reasons.Add("Trusted publisher")
            }
        }
        else {
            $Score += $Weights.MissingExecutable
            $Reasons.Add("Executable not available")
        }

        if ($Process.Path) {
            if (Test-SuspiciousLocation -Path $Process.Path -Config $Config) {
                $Score += $Weights.UserWritableLocation
                $Reasons.Add("Running from Suspicious Location")
            }

            if ($Process.Path -match "^C:\Windows\System32") {
                $Score += $Weights.SystemDirectory
                $Reasons.Add("Windows system directory")
            }
        }

        if ($ConnectionCounts.ContainsKey($Process.PID)) {
            $Count = $ConnectionCounts[$Process.PID]

            if ($Count -gt 15) {
                $Score += $Weights.ManyConnections
                $Reasons.Add("Many active TCP connections")
            }
        }
        else {
            $Count = 0
        }

        [PSCustomObject]@{
            ProcessName = $Process.ProcessName
            PID = $Process.PID
            Path = $Process.Path
            RiskScore = $Score
            RiskLevel = Get-RiskLevel -Score $Score
            ConnectionCount = $Count
            Reasons = ($Reasons -join "; ")
        }
    }

    return $Results
}

Export-ModuleMember -Function Get-RiskLevel, Invoke-RiskEngine
